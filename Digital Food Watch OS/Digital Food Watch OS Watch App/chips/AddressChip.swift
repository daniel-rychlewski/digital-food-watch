import SwiftUI

struct AddressChip: View {
    var useInternationalNames: Bool
    
    @State var isFirstStart: Bool
    @State var isValid: Bool

    var contentColor: Color {
        return Color(hex:
            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
            ) ["fields"] as? [String: Any] ?? [:]
            ) ["chip"] as? [String: Any] ?? [:]
            ) ["mapValue"] as? [String: Any]) ?? [:]
            ) ["fields"] as? [String: Any] ?? [:]
            ) ["addressContentColor"] as? [String: Any] ?? [:]
            ) ["stringValue"] as! String
        )
    }
    
    init(useInternationalNames: Bool) {
        self.useInternationalNames = useInternationalNames
        self.isFirstStart = true
        self.isValid = true
    }
    
    var body: some View {
        VStack(spacing: 20) {
            NavigationLink(destination: ContactActivity(useInternationalNames: useInternationalNames)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "contactData", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
                    )
                    .lineLimit(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["addressLabelMaxLines"] as? [String: Any] ?? [:]
                            ) ["integerValue"] as? Int
                    )
                    .truncationMode(.tail)
                    .attemptBold()
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))

                    if (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["chip"] as? [String: Any] ?? [:]
                              ) ["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["isContactDataSecondaryLabelEnabled"] as? [String: Any] ?? [:]
                              ) ["booleanValue"] as! Bool) {

                        Text(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "enterContactData", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
                        )
                        .lineLimit(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["addressSecondaryLabelMaxLines"] as? [String: Any] ?? [:]
                            ) ["integerValue"] as? Int
                            )
                        .truncationMode(.tail)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                    }
                }
                .frame(maxWidth: .infinity, minHeight:
                    CGFloat(
                        (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["main"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["height"] as? [String: Any] ?? [:]
                        ) ["integerValue"] as? Int) ?? 0
                    ), alignment: .leading
                )
                .foregroundColor(contentColor)
                .onAppear {
                    self.isValid = DataHolder.isContactDataValid()
                }
                .onDisappear {
                    if (self.isFirstStart) {
                        self.isFirstStart = false
                    }
                }
                .padding(.bottom,
                    CGFloat(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["main"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["paddingBottom"] as? [String: Any] ?? [:]
                        ) ["integerValue"] as? Int ?? 0
                    )
                )
                .ifMorePaddingNeeded { view in
                    view.padding(.vertical, 6)
                }
            }
            .ifMorePaddingNeeded { view in
                view.padding(.horizontal, 16)
            }
            .background((!isFirstStart && !isValid) ? Color(hex:
                                                                                                                                                                    ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                                                    ) ["main"] as? [String: Any] ?? [:]
                                                                                                                                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                                                    ) ["contactCardErrorColor"] as? [String: Any] ?? [:]
                                                                                                                                                                    ) ["stringValue"] as! String
                                                                                                                                                                ) : Color(hex:
                                                                                                                                                                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                                                            ) ["main"] as? [String: Any] ?? [:]
                                                                                                                                                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                                                            ) ["contactCardColor"] as? [String: Any] ?? [:]
                                                                                                                                                                            ) ["stringValue"] as! String
                                                                                                                                                                        ))
            .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
        }
    }
}
