import SwiftUI

struct CartChip: View {
    @State var error: Bool = false
    @State var isCartChipEnabled: Bool = true
    
    @State var totalPrice: Double
    var useInternationalNames: Bool
    
    @State var priceLine: String
    @State var numberOfElements: Int
    @State var totalPriceFormatted: String
    @State var minimumOrderValueText: String
    @State var isClicked: Bool

    init(totalPrice: Double, useInternationalNames: Bool) {
        self.totalPrice = totalPrice
        self.useInternationalNames = useInternationalNames
        
        // the ones below will be initialized properly in the onAppear. Here in the constructor, it's just some dummy values
        self.priceLine = ""
        self.numberOfElements = 0
        self.totalPriceFormatted = ""
        self.minimumOrderValueText = ""
        self.isClicked = false
    }

    var color: Color {
        if error {
            return Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                  ) ["fields"] as? [String: Any] ?? [:]
                                  ) ["chip"] as? [String: Any] ?? [:]
                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                  ) ["fields"] as? [String: Any] ?? [:]
                                  ) ["cartMinimumOrderValueErrorColor"] as? [String: Any] ?? [:]
                                  ) ["stringValue"] as! String
            )
        } else {
            return Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                  ) ["fields"] as? [String: Any] ?? [:]
                                  ) ["chip"] as? [String: Any] ?? [:]
                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                  ) ["fields"] as? [String: Any] ?? [:]
                                  ) ["cartMinimumOrderValueColor"] as? [String: Any] ?? [:]
                                  ) ["stringValue"] as! String
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            NavigationLink(destination: CartActivity(useInternationalNames: useInternationalNames)) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["chip"] as? [String: Any] ?? [:]
                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) [DataHolder.internationalizeLabel(labelName: "cart", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                ) ["stringValue"] as! String
                    )
                    .lineLimit(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["chip"] as? [String: Any] ?? [:]
                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                ) ["fields"] as? [String: Any] ?? [:]
                                ) ["cartLabelMaxLines"] as? [String: Any] ?? [:]
                                ) ["integerValue"] as? Int
                    )
                    .truncationMode(.tail)
                    .attemptBold()
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    
                    Text(priceLine)
                    .lineLimit(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["chip"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["cartSecondaryLabelFirstMaxLines"] as? [String: Any] ?? [:]
                                    ) ["integerValue"] as? Int
                    )
                    .truncationMode(.tail)
                    .font(.system(size: 15))
                    
                    Text(minimumOrderValueText)
                    .lineLimit(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["chip"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["cartSecondaryLabelSecondMaxLines"] as? [String: Any] ?? [:]
                                    ) ["integerValue"] as? Int
                    )
                    .truncationMode(.tail)
                    .foregroundColor((!error || !isClicked)
                                             ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["chip"] as? [String: Any] ?? [:]
                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["cartMinimumOrderValueColor"] as? [String: Any] ?? [:]
                                                              ) ["stringValue"] as! String)
                                             : color
                    )
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
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
                        ),
                        alignment: .leading
                )
                .foregroundColor(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["chip"] as? [String: Any] ?? [:]
                                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["cartChipContentColor"] as? [String: Any] ?? [:]
                                                ) ["stringValue"] as! String)
                )
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
                    view.padding(.vertical, 8)
                }
            }
            .ifMorePaddingNeeded { view in
                view.padding(.horizontal, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous)
                    .fill(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["chip"] as? [String: Any] ?? [:]
                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["cartChipBackgroundColor"] as? [String: Any] ?? [:]
                                           ) ["stringValue"] as! String))
            )
            .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
            .disabled(!isCartChipEnabled)
            .simultaneousGesture(TapGesture().onEnded {
                isClicked = true
            })
            .onAppear {
                numberOfElements = DataHolder.calculateNumberOfProducts(cart: DataHolder.cart, options: DataHolder.options)
                
                totalPrice = DataHolder.totalPrice
                totalPriceFormatted = DataHolder.formatPrice(price: totalPrice, includeCurrency: true)
                
                // TODO: it is not updating the color, and the text, in time, based on the current total amount. fix this. also, upon first load, the saved zip (if exists) shall be considered, so that the last line is not completely blank. try to switch Lieferung to Abholung. the text should switch from "keine Lieferung möglich" to "keine Abholung möglich", but does not
                minimumOrderValueText = getMinimumOrderValueText(useInternationalNames: useInternationalNames)
                
                isClicked = false
                
                if numberOfElements != 1 {
                    priceLine = "\(numberOfElements) " +
                    (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "elements", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String) + " - \(totalPriceFormatted)"
                } else {
                    priceLine = "\(numberOfElements) " +
                    (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "element", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String) + " - \(totalPriceFormatted)"
                }

                if totalPrice >= getMinimumOrderValuePrice() && (DataHolder.deliveryMode == "collection" || DataHolder.deliveryMode == "dine-in" || DataHolder.isZipCodeValid()) && !DataHolder.cart.isEmpty {
                    error = false
                } else {
                    error = true
                }

                isCartChipEnabled = DataHolder.isContactDataValid() && !error
            }
        }
    }
}
