import SwiftUI
import Foundation
import Combine
import FirebaseStorage

private let apiKey = "redacted"

func jsonString(from dictionary: [String: Any]) -> String? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8)
    } catch {
        print("Error converting dictionary to JSON string: \(error)")
        return nil
    }
}

class FirestoreViewModel: ObservableObject {
    @Published var documentData: [String: Any]?
    @Published var globalData: [String: Any]?

    func fetchDocument(useInternationalNames: Bool, completion: @escaping (String?) -> ()) {
        let areDocumentsLoaded = self.getConfirmationAndTos(useInternationalNames: useInternationalNames, completion: completion)

        if areDocumentsLoaded {
            FirebaseAPI.shared.signIn { result in
                switch result {
                    case .success((let idToken, let refreshToken)):
                        TokenManager.shared.storeToken(idToken: idToken, refreshToken: refreshToken, expiresIn: 3600)
                        self.getDocument(completion: completion)
                    case .failure(let error):
                        print("Error signing in: \(error)")
                        completion("loginError")
                }
            }
        }
    }

    private func getDocument(completion: @escaping (String?) -> ()) {
        if let idToken = TokenManager.shared.getToken() {
            FirebaseAPI.shared.getDocument(idToken: idToken, collection: Constants.Firebase.collection, document: Constants.Firebase.document) { result in
                switch result {
                case .success(let documentData):
                    if let data = documentData.data(using: .utf8) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            self.documentData = json
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error fetching document: \(error)")
                    completion("internetError")
                }
            }
            FirebaseAPI.shared.getDocument(idToken: idToken, collection: Constants.Firebase.globalCollection, document: Constants.Firebase.globalDocument) { result in
                switch result {
                case .success(let globalData):
                    if let data = globalData.data(using: .utf8) {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            self.globalData = json
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                case .failure(let error):
                    print("Error fetching document: \(error)")
                    completion("internetError")
                }
            }
        } else {
            TokenManager.shared.refreshToken { result in
                switch result {
                case .success(_):
                    self.getDocument(completion: completion)
                case .failure(let error):
                    print("Error refreshing token: \(error)")
                }
            }
        }
    }

    private func getConfirmationAndTos(useInternationalNames: Bool, completion: @escaping (String?) -> ()) -> Bool {
        if let data = NSDataAsset(name: "confirmation.html")?.data {
            DataHolder.confirmationTemplate = String(data: data, encoding: .utf8)
        } else {
            print("Error reading confirmation.html")
            completion("internalError")
            return false
        }

        if let data = NSDataAsset(name: useInternationalNames ? "tosEn.txt" : "tos.txt")?.data {
            DataHolder.tos = String(data: data, encoding: .utf8)
        } else {
            print("Error reading tos.txt")
            completion("internalError")
            return false
        }

        if let data = NSDataAsset(name: useInternationalNames ? "imprintEn.txt" : "imprint.txt")?.data {
            DataHolder.imprint = String(data: data, encoding: .utf8)
        } else {
            print("Error reading imprint.txt")
            completion("internalError")
            return false
        }

        return true
    }
}

class FirebaseAPI {
    static let shared = FirebaseAPI()
    private let baseURL = "redacted"

    private init() {}

    func signIn(completion: @escaping (Result<(String, String), Error>) -> Void) {
        let signInEndpoint = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(apiKey)"
        guard let url = URL(string: signInEndpoint) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "email": "redacted",
            "password": "redacted",
            "returnSecureToken": true
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let idToken = json?["idToken"] as? String,
                       let refreshToken = json?["refreshToken"] as? String {
                        completion(.success((idToken, refreshToken)))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
        }.resume()
    }


    func getDocument(idToken: String, collection: String, document: String, completion: @escaping (Result<String, Error>) -> Void) {
        let documentPath = "/" + collection + "/" + document
        let url = URL(string: "\(baseURL)\(documentPath)")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data {
                completion(.success(String(data: data, encoding: .utf8) ?? ""))
            } else {
                completion(.failure(NSError(domain: "com.example", code: -1, userInfo: nil)))
            }
        }.resume()
    }
}

class TokenManager {
    static let shared = TokenManager()

    private var idToken: String?
    private var refreshToken: String?
    private var expirationDate: Date?

    private init() {}

    func storeToken(idToken: String, refreshToken: String, expiresIn: TimeInterval) {
        self.idToken = idToken
        self.refreshToken = refreshToken
        self.expirationDate = Date().addingTimeInterval(expiresIn)
    }

    func getToken() -> String? {
        guard let idToken = idToken, let expirationDate = expirationDate, Date() < expirationDate else {
            return nil
        }
        return idToken
    }

    func refreshToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let refreshToken = refreshToken else {
            completion(.failure(NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Refresh token not available"])))
            return
        }

        let refreshTokenEndpoint = "https://securetoken.googleapis.com/v1/token?key=\(apiKey)"
        guard let url = URL(string: refreshTokenEndpoint) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        request.httpBody = requestBody.percentEncoded()

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let newIdToken = json?["id_token"] as? String,
                       let newRefreshToken = json?["refresh_token"] as? String,
                       let expiresIn = json?["expires_in"] as? TimeInterval {
                        self.storeToken(idToken: newIdToken, refreshToken: newRefreshToken, expiresIn: expiresIn)
                        completion(.success(newIdToken))
                    } else {
                        completion(.failure(NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse refreshed token"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received while refreshing token"])))
            }
        }.resume()
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
