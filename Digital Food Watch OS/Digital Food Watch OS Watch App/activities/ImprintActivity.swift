import SwiftUI

struct ImprintActivity: View {
    var useInternationalNames: Bool = false

    var body: some View {
        var imprintText = DataHolder.imprint ?? ""
        imprintText = imprintText.replacingOccurrences(of: "#globalAddress1", with: (((((((DataHolder.global
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["line1"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        imprintText = imprintText.replacingOccurrences(of: "#globalAddress2", with: (((((((DataHolder.global
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["line2"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        imprintText = imprintText.replacingOccurrences(of: "#globalAddress3", with: (((((((DataHolder.global
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["address"] as? [String: Any] ?? [:]
                                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["line3"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)
        imprintText = imprintText.replacingOccurrences(of: "#globalEmailAddress", with: (((DataHolder.global
                                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                                      ) ["email"] as? [String: Any] ?? [:]
                                                                                      ) ["stringValue"] as! String)

        return ScrollView {
            VStack {
                Text(
                    ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                    ) ["fields"] as? [String: Any] ?? [:]
                    ) ["imprint"] as? [String: Any] ?? [:]
                    ) ["mapValue"] as? [String: Any]) ?? [:]
                    ) ["fields"] as? [String: Any] ?? [:]
                    ) [DataHolder.internationalizeLabel(labelName: "legalNoticeHeadline", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                    ) ["stringValue"] as! String
                )
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)

                Text(imprintText)
            }
        }
    }
}
