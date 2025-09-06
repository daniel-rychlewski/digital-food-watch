import SwiftUI

struct FoodOverviewChip: View {
    var useInternationalNames: Bool
    
    init(useInternationalNames: Bool) {
        self.useInternationalNames = useInternationalNames
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text(
                    ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["chip"] as? [String: Any] ?? [:]
                          ) ["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) [DataHolder.internationalizeLabel(labelName: "foodOverview", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                          ) ["stringValue"] as! String
                )
                .attemptBold()
                .multilineTextAlignment(.leading)
                .padding(.leading, 10)
                .padding(.vertical, 18)
                .font(.system(size: 15))
                
            }
            .frame(maxWidth: .infinity, minHeight: CGFloat(
                (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                ) ["fields"] as? [String: Any] ?? [:]
                ) ["main"] as? [String: Any] ?? [:]
                ) ["mapValue"] as? [String: Any]) ?? [:]
                ) ["fields"] as? [String: Any] ?? [:]
                ) ["height"] as? [String: Any] ?? [:]
                ) ["integerValue"] as? Int) ?? 0
            ), alignment: .leading)
            .foregroundColor(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["chip"] as? [String: Any] ?? [:]
                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["foodOverviewChipContentColor"] as? [String: Any] ?? [:]
                                            ) ["stringValue"] as! String))
            .ifMorePaddingNeeded { view in
                view.padding(.horizontal, 16)
            }
            .padding(.bottom,
                     ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["main"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["paddingBottom"] as? [String: Any] ?? [:]
                            ) ["integerValue"] as? CGFloat ?? 0
            )
            .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous)
                .fill(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                       ) ["fields"] as? [String: Any] ?? [:]
                                       ) ["chip"] as? [String: Any] ?? [:]
                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                       ) ["fields"] as? [String: Any] ?? [:]
                                       ) ["foodOverviewChipBackgroundColor"] as? [String: Any] ?? [:]
                                       ) ["stringValue"] as! String)))
            .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
        }
    }
}
