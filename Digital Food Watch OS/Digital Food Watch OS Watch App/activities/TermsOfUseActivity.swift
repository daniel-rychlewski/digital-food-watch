import SwiftUI

struct TermsOfUseActivity: View {
    var useInternationalNames: Bool = false

    var body: some View {
        var tosText = DataHolder.tos ?? ""
        tosText = tosText.replacingOccurrences(of: "#globalAddress1", with: (((((((DataHolder.global
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["line1"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        tosText = tosText.replacingOccurrences(of: "#globalAddress2", with: (((((((DataHolder.global
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["line2"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        tosText = tosText.replacingOccurrences(of: "#globalAddress3", with: (((((((DataHolder.global
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["line3"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        tosText = tosText.replacingOccurrences(of: "#globalEmailAddress", with: (((DataHolder.global
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["email"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        tosText = tosText.replacingOccurrences(of: "#restaurantAddress1", with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address1"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        tosText = tosText.replacingOccurrences(of: "#restaurantAddress2", with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address2"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        tosText = tosText.replacingOccurrences(of: "#restaurantAddress3", with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address3"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        tosText = tosText.replacingOccurrences(of: "#restaurantPhoneNumber", with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                         ) ["fields"] as? [String: Any] ?? [:]
                                                                                         ) ["phoneNumber"] as? [String: Any] ?? [:]
                                                                                         ) ["stringValue"] as! String)

        return ScrollView {
            VStack {
                Text(
                    ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["terms"] as? [String: Any] ?? [:]
                          ) ["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) [DataHolder.internationalizeLabel(labelName: "termsOfUseHeadlineText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                          ) ["stringValue"] as! String
                )
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

                Text(tosText)
            }
        }
    }
}
