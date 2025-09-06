import SwiftUI

struct ModeChip: View {
    var useInternationalNames: Bool

    var contentColor: Color {
        return Color(hex:
            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
            ) ["fields"] as? [String: Any] ?? [:]
            ) ["chip"] as? [String: Any] ?? [:]
            ) ["mapValue"] as? [String: Any]) ?? [:]
            ) ["fields"] as? [String: Any] ?? [:]
            ) ["deliveryModeContentColor"] as? [String: Any] ?? [:]
            ) ["stringValue"] as! String)
    }
    
    init(useInternationalNames: Bool) {
        self.useInternationalNames = useInternationalNames
    }

    var body: some View {
        VStack(spacing: 20) {
            NavigationLink(destination: ModeActivity(useInternationalNames: useInternationalNames)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["chip"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "deliveryModeData", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["chip"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["deliveryModeLabelMaxLines"] as? [String: Any] ?? [:]
                        ) ["integerValue"] as? Int)
                    .truncationMode(.tail)
                    .attemptBold()
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))

                    if (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["chip"] as? [String: Any] ?? [:]
                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["isDeliveryModeSecondaryLabelEnabled"] as? [String: Any] ?? [:]
                                ) ["booleanValue"] as! Bool) {
                        Text(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["chip"] as? [String: Any] ?? [:]
                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) [DataHolder.internationalizeLabel(labelName: "chooseDeliveryMode", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                ) ["stringValue"] as! String)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["chip"] as? [String: Any] ?? [:]
                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["deliveryModeSecondaryLabelMaxLines"] as? [String: Any] ?? [:]
                                ) ["integerValue"] as? Int
                        )
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                    }
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
                .foregroundColor(contentColor)
                .padding(.bottom,
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["main"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["paddingBottom"] as? [String: Any] ?? [:]
                        ) ["integerValue"] as? CGFloat ?? 0
                )
                .ifMorePaddingNeeded { view in
                    view.padding(.vertical, 6)
                }
            }
            .ifMorePaddingNeeded { view in
                view.padding(.horizontal, 16)
            }
        }
        .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous).fill(DataHolder.deliveryMode == "" ? Color(hex:
                                                                                                                                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                            ) ["main"] as? [String: Any] ?? [:]
                                                                                                                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                            ) ["deliveryModeCardErrorColor"] as? [String: Any] ?? [:]
                                                                                                                                            ) ["stringValue"] as! String
                                                                                                                                        ) : Color(hex:
                                                                                                                                                    ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                                    ) ["main"] as? [String: Any] ?? [:]
                                                                                                                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                                    ) ["deliveryModeCardColor"] as? [String: Any] ?? [:]
                                                                                                                                                    ) ["stringValue"] as! String
                                                                                                                                                )))
        .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
    }
}
