import SwiftUI

struct ImprintChip: View {
    var useInternationalNames: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            NavigationLink(destination: ImprintActivity(useInternationalNames: useInternationalNames)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) ["chip"] as? [String: Any] ?? [:]
                               ) ["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "imprintLabelText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String)
                    .attemptBold()
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                }
                .frame(maxWidth: .infinity, minHeight: CGFloat((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["main"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["height"] as? [String: Any] ?? [:]
                        ) ["integerValue"] as? Int) ?? 0), alignment: .leading)
                .foregroundColor(Color(hex:((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                     ) ["fields"] as? [String: Any] ?? [:]
                                                     ) ["chip"] as? [String: Any] ?? [:]
                                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                                     ) ["fields"] as? [String: Any] ?? [:]
                                                     ) ["imprintChipContentColor"] as? [String: Any] ?? [:]
                                                     ) ["stringValue"] as! String))
            }
            .ifMorePaddingNeeded { view in
                view.padding(.horizontal, 16)
            }
            .padding(.bottom, ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["main"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["paddingBottom"] as? [String: Any] ?? [:]
                                   ) ["integerValue"] as? CGFloat ?? 0
            )
            .background(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["chip"] as? [String: Any] ?? [:]
                                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["imprintChipBackgroundColor"] as? [String: Any] ?? [:]
                                                ) ["stringValue"] as! String))
            .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
        }
    }
}
