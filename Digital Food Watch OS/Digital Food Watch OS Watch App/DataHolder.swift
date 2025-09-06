import SwiftUI
import Combine
import OrderedCollections
import Foundation

class DataHolder: ObservableObject {
    // The cart contains the food that the user orders. It maps id to amount.
    static var cart = OrderedDictionary<Int, Int>()
    // Upon app startup, the available food is populated from Firestore.
    static var food: [Food] = []
    /* Upon app startup, the available options are populated from Firestore.
    They map the id of the option to the option for the purpose of easier lookup by id. */
    static var options: [Int: OptionContent] = [:]
    /* Mapping of a food to its selected options. E.g.,
    { 10 -> { [32, 111], [34], [35, 111, 112], [35] } }
    For the food with id 10, which has two options, i.e. one single-option (containing options with the ids 32, 34, 35)
    and one multi-option (containing options with the ids 111, 112), and has been selected 4 times. */
    static var foodToOptionsMapping = OrderedDictionary<Int, OrderedSet<OrderedSet<Int>>>()

    static var guiConfig: [String: Any] = [:]
    static var restaurantConfig: [String: Any] = [:]
    static var emailConfig: [String: [String: Any]] = [:]
    static var stripeConfig: [String: [String: Any]] = [:]
    static var whatsAppConfig: [String: [String: Any]] = [:]
    static var commission: [String: [String: Any]] = [:]

    static var minimumAllowedAppVersion: String?
    static var activeCardPaymentMode: String?
    static var cryptoApiKey: String?
    static var currencyExchangeApiKey: String?
    
    static var useWhatsApp: Bool?
    static var isActive: Bool?
    static var isCardPaymentSupported: Bool?
    static var isCryptoPaymentSupported: Bool?

    static var global: [String: Any] = [:]
    
    static var confirmationTemplate: String?
    static var tos: String?
    static var imprint: String?
    
    static var paymentLinkId: String?

    static var name: String? = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                ) ["fields"] as? [String: Any] ?? [:]
                                                                                ) ["main"] as? [String: Any] ?? [:]
                                                                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                ) ["fields"] as? [String: Any] ?? [:]
                                                                                ) ["savedNameKey"] as? [String: Any] ?? [:]
                                                                                ) ["stringValue"] as? String
                                                                                ?? "name")
    static var email: String? = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["main"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["savedEmailKey"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as? String
                                                                           ?? "email")
    static var street: String? = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["main"] as? [String: Any] ?? [:]
                                                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["savedStreetKey"] as? [String: Any] ?? [:]
                                                                            ) ["stringValue"] as? String
                                                                            ?? "street")
    static var zip: String? = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                         ) ["fields"] as? [String: Any] ?? [:]
                                                                         ) ["main"] as? [String: Any] ?? [:]
                                                                         ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                         ) ["fields"] as? [String: Any] ?? [:]
                                                                         ) ["savedZipKey"] as? [String: Any] ?? [:]
                                                                         ) ["stringValue"] as? String
                                                                         ?? "zip")
    static var city: String? = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                          ) ["fields"] as? [String: Any] ?? [:]
                                                                          ) ["main"] as? [String: Any] ?? [:]
                                                                          ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                          ) ["fields"] as? [String: Any] ?? [:]
                                                                          ) ["savedCityKey"] as? [String: Any] ?? [:]
                                                                          ) ["stringValue"] as? String
                                                                          ?? "city")
    static var phoneNumber: String? = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["main"] as? [String: Any] ?? [:]
                                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["savedPhoneNumberKey"] as? [String: Any] ?? [:]
                                                                                 ) ["stringValue"] as? String
                                                                                 ?? "phoneNumber")
    static var instructions: String? = UserDefaults.standard.string(forKey: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["main"] as? [String: Any] ?? [:]
                                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["savedInstructionsKey"] as? [String: Any] ?? [:]
                                                                                 ) ["stringValue"] as? String
                                                                                 ?? "instructions")
    
    @AppStorage("deliveryMode") static var deliveryMode: String = ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                        ) ["mode"] as? [String: Any] ?? [:]
                                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                                        ) ["defaultMode"] as? [String: Any] ?? [:]
                                                                        ) ["stringValue"] as? String ?? ""

    static var totalPrice = 0.0

    // All chosen options of a main food shall be below the main food. After that, the next main food will be shown, and all chosen options for that shall be below it, etc.
    static func reorderCart() {
        var newCart = OrderedDictionary<Int, Int>()
        var mainFoodMap = OrderedDictionary<Int, Int>()

        DataHolder.cart.forEach { (id, amount) in
            if DataHolder.food.first(where: { $0.id == id }) != nil {
                mainFoodMap[id] = amount
            }
        }

        mainFoodMap.forEach { (id, amount) in
            newCart[id] = amount
            let options = Array(OrderedSet(DataHolder.foodToOptionsMapping[id]?.flatMap { $0 } ?? []))
            options.forEach { option in
                if let found = DataHolder.cart[option] {
                    newCart[option] = found
                }
            }
        }

        DataHolder.cart = newCart
    }
    
    // Calculates the number of products in the cart as displayed to the user. This does not include options.
    static func calculateNumberOfProducts(cart: OrderedDictionary<Int, Int>, options: [Int: OptionContent]) -> Int {
        if cart.isEmpty {
            return 0
        }
        var count = 0
        cart.forEach { entry in
            if !options.keys.contains(entry.key) {
                count += entry.value
            }
        }
        return count
    }

    static func calculateCartPrice(cart: OrderedDictionary<Int, Int>) -> Double {
        var total = 0.0
        cart.forEach { (id, quantity) in
            let price: Double? = DataHolder.food.first { $0.id == id }?.price
            if let price = price {
                total += price * Double(quantity)
            } else {
                let optionPrice: Double = DataHolder.options[id]?.price ?? 0.0
                total += optionPrice * Double(quantity)
            }
        }
        return total
    }

    static func formatPrice(price: Double, includeCurrency: Bool = true) -> String {
        let restaurantConfig = DataHolder.restaurantConfig
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        formatter.locale = Locale.current

        let thousands = price / 1000
        
        var formattedPrice: String = formatter.string(from: NSNumber(value: thousands)) ?? ""
        formattedPrice = formattedPrice.replacingOccurrences(of: ",", with: ",").replacingOccurrences(of: ".", with: ",").trimmingCharacters(in: .whitespaces)
        if formattedPrice.hasSuffix(",00") {
            formattedPrice = formattedPrice.replacingOccurrences(of: ",00", with: "")
        }

        if includeCurrency && price != 0.0 {
            formattedPrice += ((((restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                    ) ["fields"] as? [String: Any] ?? [:]
                    ) ["currency"] as? [String: Any] ?? [:]
                    ) ["stringValue"] as? String ?? ""
        }

        return formattedPrice
    }
    
    static func getPaymentLink(unitAmount: String, email: String, currency: String, useInternationalNames: Bool, completion: @escaping (String?) -> ()) {
        let secretKey = ((((((((((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                             ) ["fields"] as? [String: Any] ?? [:]
                             ) ["apiKey"] as? [String: Any] ?? [:]
                             ) ["mapValue"] as? [String: Any]) ?? [:]
                             ) ["fields"] as? [String: Any] ?? [:]
                             ) [DataHolder.activeCardPaymentMode!] as? [String: Any] ?? [:]
                             ) ["mapValue"] as? [String: Any]) ?? [:]
                             ) ["fields"] as? [String: Any] ?? [:]
                             ) ["secretKey"] as? [String: Any] ?? [:]
                             ) ["stringValue"] as! String

        let priceRequestEndpoint = ((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                                             ) ["fields"] as? [String: Any] ?? [:]
                                             ) ["priceEndpoint"] as? [String: Any] ?? [:]
                                             ) ["stringValue"] as! String

        let priceRequestUrl = URL(string: priceRequestEndpoint)
        var priceRequest = URLRequest(url: priceRequestUrl!)
        priceRequest.httpMethod = "POST"
        priceRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        priceRequest.addValue("Bearer "+secretKey, forHTTPHeaderField: "Authorization")

        let orderName = ((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "orderName", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String

        let priceRequestData: [String: Any] = [
            "currency": currency,
            "product_data[name]": orderName,
            "unit_amount": unitAmount
        ]

        let priceRequestBody = priceRequestData.map { key, value in
            return "\(key)=\(value)"
        }.joined(separator: "&")

        priceRequest.httpBody = priceRequestBody.data(using: .utf8)

        URLSession.shared.dataTask(with: priceRequest) { data, response, error in
            if let error = error {
                print("Price request error: \(error)")
            }

            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let priceId = json?["id"] as? String {

                        let publicKey = ((((((((((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                                             ) ["fields"] as? [String: Any] ?? [:]
                                             ) ["apiKey"] as? [String: Any] ?? [:]
                                             ) ["mapValue"] as? [String: Any]) ?? [:]
                                             ) ["fields"] as? [String: Any] ?? [:]
                                             ) [DataHolder.activeCardPaymentMode!] as? [String: Any] ?? [:]
                                             ) ["mapValue"] as? [String: Any]) ?? [:]
                                             ) ["fields"] as? [String: Any] ?? [:]
                                             ) ["publicKey"] as? [String: Any] ?? [:]
                                             ) ["stringValue"] as! String
                        
                        let paymentSuccessMessage = ((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                                             ) ["fields"] as? [String: Any] ?? [:]
                                             ) [DataHolder.internationalizeLabel(labelName: "paymentSuccessMessageWatchOs", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                             ) ["stringValue"] as! String
                        
                        let paymentLinksRequestEndpoint = ((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                                                             ) ["fields"] as? [String: Any] ?? [:]
                                                             ) ["paymentLinkEndpoint"] as? [String: Any] ?? [:]
                                                             ) ["stringValue"] as! String
                        let paymentLinksRequestUrl = URL(string: paymentLinksRequestEndpoint)
                        var paymentLinksRequest = URLRequest(url: paymentLinksRequestUrl!)
                        paymentLinksRequest.httpMethod = "POST"
                        paymentLinksRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        paymentLinksRequest.addValue("Bearer "+secretKey, forHTTPHeaderField: "Authorization")

                        let paymentLinksData: [String: Any] = [
                            "line_items[0][price]": priceId,
                            "line_items[0][quantity]": "1",
                            "after_completion[hosted_confirmation][custom_message]": paymentSuccessMessage,
                            "after_completion[type]": "hosted_confirmation",
                            "payment_method_types[0]": "card"
                        ]
                        
                        let paymentLinksBody = paymentLinksData.map { key, value in
                            return "\(key)=\(value)"
                        }.joined(separator: "&")

                        paymentLinksRequest.httpBody = paymentLinksBody.data(using: .utf8)

                        URLSession.shared.dataTask(with: paymentLinksRequest) { data, response, error in
                            if let error = error {
                                print("Payment links request error: \(error)")
                            }

                            if let data = data {
                                do {
                                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                                    if let paymentLinkResultUrl = json?["url"] as? String {
                                        DataHolder.paymentLinkId = json?["id"] as? String
                                        completion(paymentLinkResultUrl + "?prefilled_email="+email)
                                    }
                                } catch (_) {
                                    completion(nil)
                                }
                            }
                        }.resume()
                    }
                } catch (_) {
                    completion(nil)
                }
            }
        }.resume()
    }

    static func retrieveCheckoutSession(paymentLinkId: String, secretKey: String, completion: @escaping (Bool) -> Void) {
        let paymentLinksRequestEndpoint = ((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                                             ) ["fields"] as? [String: Any] ?? [:]
                                             ) ["checkoutSessionsEndpoint"] as? [String: Any] ?? [:]
                                             ) ["stringValue"] as! String

        let url = URL(string: "\(paymentLinksRequestEndpoint)?payment_link=\(paymentLinkId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let authHeader = "Bearer \(secretKey)"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching checkout session: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let sessions = json["data"] as? [[String: Any]] {
                    // Check each session's payment status
                    for session in sessions {
                        if let status = session["payment_status"] as? String {
                            if status == "paid" || status == "succeeded" {
                                completion(true) // Successful payment found
                                return
                            }
                        }
                    }
                    completion(false) // No successful payments found
                } else {
                    print("Unexpected response format.")
                    completion(false)
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(false)
            }
        }
        
        task.resume()
    }

    static func isContactDataValid() -> Bool {
        let defaults = UserDefaults.standard
        
        let mainConfig = (((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                                     ) ["main"] as? [String: Any] ?? [:]

        let restaurantConfig = ((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
        let sampleUserContactData = (((restaurantConfig["sampleUserContactData"] as! [String: Any]
                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                     ) ["fields"] as? [String: Any] ?? [:]
                
        if DataHolder.name == nil || DataHolder.name == "" {
            let savedName = defaults.string(forKey: (mainConfig["savedNameKey"] as? [String: Any] ?? [:]) ["stringValue"] as? String ?? "")

            let sampleName = (sampleUserContactData["nameSample"] as? [String: Any] ?? [:]) ["stringValue"] as? String
            if savedName == nil {
                return false
            }
            DataHolder.name = sampleName
        }

        if useWhatsApp != true {
            if DataHolder.email == nil || DataHolder.email == "" {
                let savedEmail = defaults.string(forKey: (mainConfig["savedEmailKey"] as? [String: Any] ?? [:]) ["stringValue"] as? String ?? "")
                let sampleEmail = (sampleUserContactData["emailAddressSample"] as? [String: Any] ?? [:]) ["stringValue"] as? String
                if savedEmail == nil {
                    return false
                }
                DataHolder.email = sampleEmail
            }
        }

        if DataHolder.deliveryMode == "delivery" {
            if DataHolder.street == nil || DataHolder.street == "" {
                let savedStreet = defaults.string(forKey: (mainConfig["savedStreetKey"] as? [String: Any] ?? [:]) ["stringValue"] as? String ?? "")
                let sampleStreet = (sampleUserContactData["streetSample"] as? [String: Any] ?? [:]) ["stringValue"] as? String
                if savedStreet == nil {
                    return false
                }
                DataHolder.street = sampleStreet
            }

            if DataHolder.zip == nil || DataHolder.zip == "" {
                let savedZip = defaults.string(forKey: (mainConfig["savedZipKey"] as? [String: Any] ?? [:]) ["stringValue"] as? String ?? "")
                let sampleZip = (sampleUserContactData["zipSample"] as? [String: Any] ?? [:]) ["stringValue"] as? String
                if savedZip == nil {
                    if !isZipCodeValid() {
                        return false
                    }
                }
                DataHolder.zip = sampleZip
            }

            if DataHolder.city == nil || DataHolder.city == "" {
                let savedCity = defaults.string(forKey: (mainConfig["savedCityKey"] as? [String: Any] ?? [:]) ["stringValue"] as? String ?? "")
                let sampleCity = (sampleUserContactData["citySample"] as? [String: Any] ?? [:]) ["stringValue"] as? String
                if savedCity == nil {
                    return false
                }
                DataHolder.city = sampleCity
            }
        }

        if DataHolder.phoneNumber == nil || DataHolder.phoneNumber == "" {
            let savedPhoneNumber = defaults.string(forKey: (mainConfig["savedPhoneNumberKey"] as? [String: Any] ?? [:]) ["stringValue"] as? String ?? "")
            let samplePhoneNumber = (sampleUserContactData["phoneNumberSample"] as? [String: Any] ?? [:]) ["stringValue"] as? String
            if savedPhoneNumber == nil {
                return false
            }
            DataHolder.phoneNumber = samplePhoneNumber
        }

        if DataHolder.instructions == nil {
            let savedInstructions = defaults.string(forKey: (mainConfig["savedInstructionsKey"] as? [String: Any] ?? [:]) ["stringValue"] as? String ?? "")
            let sampleInstructions = (sampleUserContactData["instructionsSample"] as? [String: Any] ?? [:]) ["stringValue"] as? String
            DataHolder.instructions = sampleInstructions
        }

        let nameValid = (DataHolder.name != nil && DataHolder.name != "") && ContactActivity.nameRegex.matches(in: DataHolder.name!, options: [], range: NSRange(location: 0, length: DataHolder.name!.count)).count > 0
        let emailValid = (DataHolder.email != nil && DataHolder.email != "") && ContactActivity.emailRegex.matches(in: DataHolder.email!, options: [], range: NSRange(location: 0, length: DataHolder.email!.count)).count > 0
        let phoneNumberValid = (DataHolder.phoneNumber != nil && DataHolder.phoneNumber != "") && ContactActivity.phoneNumberRegex.matches(in: DataHolder.phoneNumber!, options: [], range: NSRange(location: 0, length: DataHolder.phoneNumber!.count)).count > 0
        let instructionsValid = DataHolder.instructions != nil && ContactActivity.instructionsRegex.matches(in: DataHolder.instructions!, options: [], range: NSRange(location: 0, length: DataHolder.instructions!.count)).count > 0
        
        let streetValid = (DataHolder.street != nil && DataHolder.street != "") && ContactActivity.streetRegex.matches(in: DataHolder.street!, options: [], range: NSRange(location: 0, length: DataHolder.street!.count)).count > 0
        let zipValid = (DataHolder.zip != nil && DataHolder.zip != "") && ContactActivity.zipRegex.matches(in: DataHolder.zip!, options: [], range: NSRange(location: 0, length: DataHolder.zip!.count)).count > 0
        let cityValid = (DataHolder.city != nil && DataHolder.city != "") && ContactActivity.cityRegex.matches(in: DataHolder.city!, options: [], range: NSRange(location: 0, length: DataHolder.city!.count)).count > 0

        if (DataHolder.deliveryMode == "delivery") {
            return nameValid && (useWhatsApp == true || emailValid) && phoneNumberValid && streetValid && zipValid && cityValid && instructionsValid
        } else {
            return nameValid && (useWhatsApp == true || emailValid) && phoneNumberValid && instructionsValid
        }

    }

    static func isZipCodeValid() -> Bool {
        let restaurantConfig = ((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]

        guard let minimumOrderValueMap = (((restaurantConfig["minimumOrderMap"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] else {
            return true
        }

        if let zipCode = DataHolder.zip, !minimumOrderValueMap.isEmpty {
            return minimumOrderValueMap[zipCode] != nil
        }

        return true
    }

    static func internationalizeLabel(labelName: String, useInternationalNames: Bool) -> String {
        return labelName + (useInternationalNames ? "En" : "")
    }
    
    /*
    * Compares two versions semantically, for example:
    * "1.0" and "1.0.1" -> returns < 0
    * "1.0.1" and "1.0" -> returns > 0
    * "1.0" and "1.0.0" -> returns 0
    * non-numeric input like "test" -> throws exception
    * further edge cases like "1a..2.3" or "1..2.3..." did not need to be considered
    */
    static func compareVersions(version1: String, version2: String) throws -> Int {
        let regex = try! NSRegularExpression(pattern: "\\d+")

        let version1Numbers = regex.matches(in: version1, range: NSRange(version1.startIndex..., in: version1))
            .map { Int((version1 as NSString).substring(with: $0.range)) }
        let version2Numbers = regex.matches(in: version2, range: NSRange(version2.startIndex..., in: version2))
            .map { Int((version2 as NSString).substring(with: $0.range)) }

        // Check for invalid versions
        guard !version1Numbers.isEmpty, !version2Numbers.isEmpty else {
            throw NSError(domain: "Invalid input", code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Invalid input: \(version1) or \(version2)"
            ])
        }

        let minLength = min(version1Numbers.count, version2Numbers.count)

        for i in 0..<minLength {
            let result = version1Numbers[i]! - version2Numbers[i]!
            if result != 0 {
                return result
            }
        }

        var version1Trimmed = version1Numbers
        while version1Trimmed.last == 0 {
            version1Trimmed.removeLast()
        }

        var version2Trimmed = version2Numbers
        while version2Trimmed.last == 0 {
            version2Trimmed.removeLast()
        }

        return version1Trimmed.count - version2Trimmed.count
    }
    
    static func toDayNames(days: [String], useInternationalNames: Bool, useShort: Bool) -> [String] {
        let locale = useInternationalNames ? Locale(identifier: "en_US") : Locale.current
        
        let formatter = DateFormatter()
        formatter.locale = locale
        
        let weekdays = useShort ? formatter.shortWeekdaySymbols! : formatter.weekdaySymbols!

        return days.map { day in
            switch day.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "sunday":    return weekdays[0]
            case "monday":    return weekdays[1]
            case "tuesday":   return weekdays[2]
            case "wednesday": return weekdays[3]
            case "thursday":  return weekdays[4]
            case "friday":    return weekdays[5]
            case "saturday":  return weekdays[6]
            default:          return day // fallback if DB value is weird
            }
        }
    }
}
