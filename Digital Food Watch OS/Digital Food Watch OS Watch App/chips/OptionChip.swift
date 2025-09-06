import SwiftUI
import OrderedCollections

struct OptionChip: View {
    var parentId: Int
    var id: Int?
    var name: String
    var nameEn: String
    var price: String?
    var bitmapImage: Image?
    var useInternationalNames: Bool
    var isFirstOption: Bool
    var isIntermediateButton: Bool
    var availableFrom: String?
    var availableTo: String?
    
    var hasSatisfiedTimeCriteria: Bool
    var isUnavailable: Bool
    
    @Binding var isSelected: Bool
    @Binding var previousOptionId: Int?
    
    @ObservedObject var viewModel: FoodActivityModel
    
    var backgroundColor: Color {
        if self.isSelected {
            return Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["chip"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["optionChipSelectedBackgroundColor"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String)
        } else {
            if hasSatisfiedTimeCriteria && !isUnavailable {
                return Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                ) ["fields"] as? [String: Any] ?? [:]
                ) ["chip"] as? [String: Any] ?? [:]
                ) ["mapValue"] as? [String: Any]) ?? [:]
                ) ["fields"] as? [String: Any] ?? [:]
                ) ["optionChipBackgroundColor"] as? [String: Any] ?? [:]
                ) ["stringValue"] as! String)
            } else {
                return Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                ) ["fields"] as? [String: Any] ?? [:]
                ) ["chip"] as? [String: Any] ?? [:]
                ) ["mapValue"] as? [String: Any]) ?? [:]
                ) ["fields"] as? [String: Any] ?? [:]
                ) ["optionChipGrayedOutBackgroundColor"] as? [String: Any] ?? [:]
                ) ["stringValue"] as! String)
            }
        }
    }
    
    var backgroundColorWithPictureOverlay: Color {
        if hasSatisfiedTimeCriteria && !isUnavailable {
            if self.isSelected {
                return Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                           ) ["chip"] as? [String: Any] ?? [:]
                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                           ) ["optionChipSelectedBackgroundColor"] as? [String: Any] ?? [:]
                                                           ) ["stringValue"] as! String)
                .opacity(0.6)
            } else {
                return Color.black.opacity(0.6)
            }
        } else {
            return Color.black.opacity(0.6)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                if hasSatisfiedTimeCriteria && !isUnavailable {
                    let prevIsSelected = isSelected
                    isSelected.toggle()
                    let hasChanged = (prevIsSelected != isSelected)

                    if hasChanged {
                        if self.isSelected {
                            if let id = id {
                                DataHolder.cart[id] = (DataHolder.cart[id] ?? 0) + 1

                                var mapping = DataHolder.foodToOptionsMapping[parentId]
                                if mapping == nil || mapping!.isEmpty {
                                    var newMapping = OrderedSet<Int>()
                                    newMapping.append(id)
                                    DataHolder.foodToOptionsMapping[parentId] = OrderedSet<OrderedSet<Int>>()
                                    DataHolder.foodToOptionsMapping[parentId]?.append(newMapping)
                                } else {
                                    if isFirstOption {
                                        var newMapping = OrderedSet<Int>()
                                        newMapping.append(id)
                                        
                                        // Roll back the previously selected option
                                        if let previous = mapping?.last?.last, previous == previousOptionId {
                                            DataHolder.cart[previous] = (DataHolder.cart[previous] ?? 0) - 1
                                            mapping?.removeLast()
                                        }
                                        
                                        mapping!.append(newMapping)
                                        DataHolder.foodToOptionsMapping[parentId] = mapping
                                    } else {
                                        var mapping = DataHolder.foodToOptionsMapping[parentId]
                                        if let options = mapping {
                                            var last = mapping?.last
                                            mapping?.removeLast()
                                            
                                            // Roll back the previously selected option
                                            if let previous = last?.last, previous == previousOptionId {
                                                DataHolder.cart[previous] = (DataHolder.cart[previous] ?? 0) - 1
                                                last?.removeLast()
                                            }

                                            last?.append(id)
                                            mapping?.append(last!)
                                        } else {
                                          mapping = OrderedSet([OrderedSet([id])])
                                        }
                                        DataHolder.foodToOptionsMapping[parentId] = mapping
                                    }
                                }
                                DataHolder.totalPrice = DataHolder.calculateCartPrice(cart: DataHolder.cart)
                                
                                if (!isIntermediateButton) {
                                    self.viewModel.isAllOptionSelectionsSuccessful = true
                                }
                                previousOptionId = id
                            }
                        }
                    }
                }
            }) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(useInternationalNames ? nameEn : name)
                        .lineLimit(
                            (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["chip"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["optionLabelMaxLines"] as? [String: Any] ?? [:]
                                   ) ["integerValue"] as? Int)
                        )
                        .truncationMode(.tail)
                        .attemptBold()
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                    
                    if !isUnavailable {
                        if price != nil {
                            Text(price! + getAvailabilityRestrictions(availableFrom: availableFrom, availableTo: availableTo, useInternationalNames: useInternationalNames, type: "option"))
                                .lineLimit(
                                    (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["chip"] as? [String: Any] ?? [:]
                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                           ) ["fields"] as? [String: Any] ?? [:]
                                           ) ["optionSecondaryLabelMaxLines"] as? [String: Any] ?? [:]
                                           ) ["integerValue"] as? Int)
                                )
                                .truncationMode(.tail)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 15))
                        }
                    } else {
                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["main"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "notAvailableText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
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
                        ),
                       alignment: .leading
                )
                .foregroundColor(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["chip"] as? [String: Any] ?? [:]
                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["optionChipContentColor"] as? [String: Any] ?? [:]
                                                  ) ["stringValue"] as! String
                                      ))
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
            .background(
                ZStack {
                    if let bitmap = bitmapImage {
                        bitmap
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .overlay(backgroundColorWithPictureOverlay)
                    } else {
                        RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous)
                            .fill(backgroundColor)
                    }
                }
            )
            .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
        }
    }
}
