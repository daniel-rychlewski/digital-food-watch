import SwiftUI
import Foundation
import Combine
import Firebase

struct SplashActivity: View {
    @StateObject private var viewModel = FirestoreViewModel()
    
    @State private var whatToStart: String = ""
    
    private var language: String?
    
    init() {
        FirebaseApp.configure()
        
        if #available(watchOS 9.0, *) {
            language = Locale.preferredLanguages.first ?? Locale.current.language.languageCode?.identifier
        } else {
            language = Locale.current.languageCode
        }
    }

    var body: some View {
        let useInternationalNames = !language!.starts(with: Constants.Firebase.localLanguage) // Locale.preferredLanguages.first can be, e.g., "de-CH"
        
        VStack {
            if self.whatToStart == "app" {
                MainActivity(useInternationalNames: useInternationalNames)
            } else if self.whatToStart == "internetError" {
                InternetError()
            } else if self.whatToStart == "loginError" {
                LoginError()
            } else if self.whatToStart == "internalError" {
                InternalError()
            } else if self.whatToStart == "restaurantClosedError" {
                RestaurantClosedError()
            } else if self.whatToStart == "updateError" {
                UpdateError()
            } else if self.whatToStart == "inactive" {
                InactiveScreen()
            } else {
                VStack {
                    Image("SplashScreen")
                        .resizable()
                        .scaledToFit()
                        .frame(width: CGFloat(Constants.UI.splashScreenWidth), height: CGFloat(Constants.UI.splashScreenHeight))
                }
            }
        }
        .onAppear {
            viewModel.fetchDocument(useInternationalNames: useInternationalNames) { whatToStart in
                if let whatToStart = whatToStart {
                    self.whatToStart = whatToStart
                }
            }
            
        }
        .onReceive(Just(viewModel.documentData)) { documentData in
            if let documentData = documentData, DataHolder.food.isEmpty {
                if let collection = documentData["fields"] as? [String: Any],
                   let config = collection["config"] as? [String: Any],
                   let mapValue = config["mapValue"] as? [String: Any],
                   let fields = mapValue["fields"] as? [String: Any] {
                    
                    let allFood = ((collection["food"] as! [String: Any])["arrayValue"] as! [String: Any])["values"] as! [[String: Any]]
                            allFood.forEach { vWrapper in
                                let v = (vWrapper["mapValue"] as! [String: Any])["fields"] as! [String: Any]

                                var options: [[String: Any]]? = (v["options"] as? [String: Any] ?? [:])["arrayValue"] as? [[String: Any]]
                                if let optionsDict = v["options"] as? [String: Any],
                                   let arrayValue = optionsDict["arrayValue"] as? [String: Any],
                                   let values = arrayValue["values"] as? [[String: Any]] {
                                    options = values
                                } else {
                                    options = nil
                                }

                                let foodItem = Food(
                                    id: Int((v["id"] as? [String: Any] ?? [:])["integerValue"] as? String ?? "0")!,
                                    background: (v["background"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                    name: (v["name"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                    nameEn: (v["nameEn"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                    description: (v["description"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                    descriptionEn: (v["descriptionEn"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                    hasImage: (v["hasImage"] as? [String: Any] ?? [:])["booleanValue"] as? Bool,
                                    isCategory: (v["isCategory"] as? [String: Any] ?? [:])["booleanValue"] as? Bool,
                                    price: ((v["price"] as? [String: Any])?["stringValue"] as? String).map { Double($0) }
                                        ??
                                        ((v["price"] as? [String: Any])?["doubleValue"] as? Double).map { $0 * 100.rounded() / 100 }
                                    ?? ((v["price"] as? [String: Any])?["integerValue"] != nil ? Double((v["price"] as? [String: Any])?["integerValue"] as! String) : nil),
                                    options: options?.isEmpty ?? true ? nil : options.flatMap { rawOptions -> Options? in
                                        let parsedOptions: [Option] = rawOptions.compactMap { optionEntry in
                                            guard let optionDict = (optionEntry["mapValue"] as? [String: Any])?["fields"] as? [String: Any] else { return nil }
                                            
                                            let configDict = ((optionDict["config"] as! [String: Any])["mapValue"] as! [String: Any])["fields"] as! [String: Any]
                                            let config = Config(
                                                mode: (configDict["mode"] as? [String: Any] ?? [:])["stringValue"] as! String,
                                                name: (configDict["name"] as? [String: Any] ?? [:])["stringValue"] as! String,
                                                nameEn: (configDict["nameEn"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                                hasImage: (configDict["hasImage"] as? [String: Any] ?? [:])["booleanValue"] as? Bool,
                                                background: (configDict["background"] as? [String: Any] ?? [:])["stringValue"] as? String
                                            )

                                            let contentArray = ((optionDict["content"] as! [String: Any])["arrayValue"] as! [String: Any])["values"] as! [[String: Any]]
                                            let content = contentArray.map { entryWrapper -> OptionContent in
                                                let entry = (entryWrapper["mapValue"] as! [String: Any])["fields"] as! [String: Any]
                                                return OptionContent(
                                                    id: Int((entry["id"] as? [String: Any] ?? [:])["integerValue"] as? String ?? "0")!,
                                                    name: (entry["name"] as? [String: Any] ?? [:])["stringValue"] as! String,
                                                    nameEn: (entry["nameEn"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                                    price: ((entry["price"] as? [String: Any])?["stringValue"] as? String).map { Double($0) }
                                                        ??
                                                        (((entry["price"] as? [String: Any])?["doubleValue"] as? Double).map { $0 * 100.rounded() / 100 }
                                                    ?? ((entry["price"] as? [String: Any])?["integerValue"] != nil ? Double((entry["price"] as? [String: Any])?["integerValue"] as! String) : nil)),
                                                    hasImage: (entry["hasImage"] as? [String: Any] ?? [:])["booleanValue"] as? Bool,
                                                    background: (entry["background"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                                    availableFrom: (entry["availableFrom"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                                    availableTo: (entry["availableTo"] as? [String: Any] ?? [:])["stringValue"] as? String
                                                )
                                            }

                                            return Option(config: config, content: content)
                                        }
                                        
                                        return Options(options: parsedOptions)
                                    },
                                    availableFrom: (v["availableFrom"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                    availableTo: (v["availableTo"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                    daysAvailable: ((v["daysAvailable"] as? [String: Any])?["arrayValue"] as? [String: Any])?["values"] as? [[String: Any]] ?? (v["daysAvailable"] == nil ? nil : []),
                                    isHidden: (v["isHidden"] as? [String: Any] ?? [:])["booleanValue"] as? Bool
                                )

                                DataHolder.food.append(foodItem)

                                if let options = options {
                                    options.forEach { optionDictWrapper in
                                        if let optionDict = (optionDictWrapper["mapValue"] as? [String: Any])?["fields"] as? [String: Any],
                                           let content = ((optionDict["content"] as? [String: Any] ?? [:])["arrayValue"] as? [String: Any])?["values"] as? [[String: Any]] {
                                            content.forEach { entryWrapper in
                                                if let entry = (entryWrapper["mapValue"] as? [String: Any])?["fields"] as? [String: Any],
                                                   let idString = (entry["id"] as? [String: Any])?["integerValue"] as? String,
                                                   let id = Int(idString) {
                                                    DataHolder.options[id] = OptionContent(
                                                        id: id,
                                                        name: (entry["name"] as? [String: Any] ?? [:])["stringValue"] as! String,
                                                        nameEn: (entry["nameEn"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                                        price: ((entry["price"] as? [String: Any])?["stringValue"] as? String).map { Double($0) }
                                                            ??
                                                            ((entry["price"] as? [String: Any])?["doubleValue"] as? Double).map { $0 * 100.rounded() / 100 }
                                                        ?? ((entry["price"] as? [String: Any])?["integerValue"] != nil ? Double((entry["price"] as? [String: Any])?["integerValue"] as! String) : nil),
                                                        hasImage: (entry["hasImage"] as? [String: Any] ?? [:])["booleanValue"] as? Bool,
                                                        background: (entry["background"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                                        availableFrom: (entry["availableFrom"] as? [String: Any] ?? [:])["stringValue"] as? String,
                                                        availableTo: (entry["availableTo"] as? [String: Any] ?? [:])["stringValue"] as? String
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                    
                    DataHolder.emailConfig = fields["email"] as! [String : [String : Any]]
                    DataHolder.stripeConfig = fields["stripe"] as! [String : [String : Any]]
                    DataHolder.whatsAppConfig = fields["whatsapp"] as! [String : [String : Any]]
                    DataHolder.guiConfig = fields["gui"] as! [String : [String : Any]]
                    DataHolder.restaurantConfig = fields["restaurant"] as! [String : [String : Any]]

                    DataHolder.commission = collection["commission"] as! [String : [String : Any]]

                    DataHolder.minimumAllowedAppVersion = (((((fields["technical"] as! [String : Any]
                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["minVersion"] as? [String: Any] ?? [:]
                                                              ) ["stringValue"] as? String

                    DataHolder.isCardPaymentSupported = (((((fields["technical"] as! [String : Any]
                                                         ) ["mapValue"] as? [String: Any]) ?? [:]
                                                         ) ["fields"] as? [String: Any] ?? [:]
                                                         ) ["isCardPaymentSupportedWatchOs"] as? [String: Any] ?? [:]
                                                         ) ["booleanValue"] as? Bool ?? nil

                    DataHolder.activeCardPaymentMode = (((((fields["technical"] as! [String : Any]
                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["activeCardPaymentMode"] as? [String: Any] ?? [:]
                                                              ) ["stringValue"] as? String
                    
                    DataHolder.cryptoApiKey = (((((fields["technical"] as! [String : Any]
                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["cryptoApiKey"] as? [String: Any] ?? [:]
                                                              ) ["stringValue"] as? String
                    
                    DataHolder.currencyExchangeApiKey = (((((fields["technical"] as! [String : Any]
                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["currencyExchangeApiKey"] as? [String: Any] ?? [:]
                                                              ) ["stringValue"] as? String

                    DataHolder.isCryptoPaymentSupported = (((((fields["technical"] as! [String : Any]
                                                         ) ["mapValue"] as? [String: Any]) ?? [:]
                                                         ) ["fields"] as? [String: Any] ?? [:]
                                                         ) ["isCryptoPaymentSupportedWatchOs"] as? [String: Any] ?? [:]
                                                         ) ["booleanValue"] as? Bool ?? nil

                    DataHolder.useWhatsApp = (((((fields["technical"] as! [String : Any]
                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                    ) ["useWhatsApp"] as? [String: Any] ?? [:]
                                                    ) ["booleanValue"] as? Bool ?? nil

                    DataHolder.isActive = (((((fields["technical"] as! [String : Any]
                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                    ) ["isActive"] as? [String: Any] ?? [:]
                                                    ) ["booleanValue"] as? Bool ?? nil

                    if DataHolder.isActive == false {
                        whatToStart = "inactive"
                    } else {
                        let isOpeningTimeSatisfied = isRestaurantCurrentlyOpen()
                        
                        if !isOpeningTimeSatisfied {
                            whatToStart = "restaurantClosedError"
                        } else {
                            let currentAppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                            print("Running app version \(currentAppVersion). The allowed minimum is version \(DataHolder.minimumAllowedAppVersion!)")

                            do {
                                guard try DataHolder.compareVersions(version1: currentAppVersion, version2: DataHolder.minimumAllowedAppVersion!) >= 0 else {
                                    whatToStart = "updateError"
                                    return
                                }

                                whatToStart = "app"
                            } catch {
                                whatToStart = "updateError" // invalid version error
                            }
                        }
                    }
                }
            }
        }
        .onReceive(Just(viewModel.globalData)) { globalData in
            if let globalData = globalData {
                DataHolder.global = globalData
            }
        }
    }
}
