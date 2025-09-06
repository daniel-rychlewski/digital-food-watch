import SwiftUI
import OrderedCollections

struct OptionMultiChip: View {
    var parentId: Int
    var id: Int?
    var name: String
    var nameEn: String
    var price: String?
    var useInternationalNames: Bool
    var isFirstOption: Bool
    var isIntermediateButton: Bool
    var availableFrom: String?
    var availableTo: String?
    
    var hasSatisfiedTimeCriteria: Bool
    var isUnavailable: Bool
    
    @Binding var isSelected: Bool
    @Binding var selectedMultiOptions: [Int]
    @State private var isChecked = false
    
    @ObservedObject var viewModel: FoodActivityModel

    var body: some View {
        Button(action: {
            if hasSatisfiedTimeCriteria && !isUnavailable {
                isChecked.toggle()

                if isChecked {
                    if let id = id {
                        DataHolder.cart[id] = (DataHolder.cart[id] ?? 0) + 1
                        DataHolder.totalPrice = DataHolder.calculateCartPrice(cart: DataHolder.cart)

                        var mapping = DataHolder.foodToOptionsMapping[parentId]
                        if mapping == nil || mapping!.isEmpty {
                            DataHolder.foodToOptionsMapping[parentId] = OrderedSet<OrderedSet<Int>>()
                            var newMapping = OrderedSet<Int>()
                            newMapping.append(id)
                            DataHolder.foodToOptionsMapping[parentId]!.append(newMapping)
                        } else {
                            if isFirstOption {
                                var newMapping = OrderedSet<Int>()
                                newMapping.append(id)
                                mapping!.append(newMapping)
                                DataHolder.foodToOptionsMapping[parentId] = mapping
                            } else {
                                var mapping = DataHolder.foodToOptionsMapping[parentId]
                                if let options = mapping {
                                    var last = mapping?.last
                                    mapping?.removeLast()
                                    last?.append(id)
                                    mapping?.append(last!)
                                } else {
                                    mapping = OrderedSet([OrderedSet([id])])
                                }
                                DataHolder.foodToOptionsMapping[parentId] = mapping
                            }
                        }
                        
                        selectedMultiOptions.append(id)
                    }
                } else {
                    // roll back this unselected option
                    if let id = id {
                        DataHolder.cart[id] = (DataHolder.cart[id] ?? 0) - 1
                        DataHolder.totalPrice = DataHolder.calculateCartPrice(cart: DataHolder.cart)

                        let mapping = DataHolder.foodToOptionsMapping[parentId]
                        if mapping != nil {
                            var mostRecentMapping = mapping![mapping!.count - 1]
                            if let index = mostRecentMapping.firstIndex(of: id) {
                                mostRecentMapping.remove(at: index)
                                DataHolder.foodToOptionsMapping[parentId]!.removeLast()
                                DataHolder.foodToOptionsMapping[parentId]!.insert(mostRecentMapping, at: mapping!.count - 1)
                            }
                        }
                        
                        selectedMultiOptions.removeAll(where: { $0 == id })
                    }
                }
            }
        }) {

                VStack(alignment: .leading) {
                    Text(useInternationalNames ? nameEn : name)
                        .lineLimit(
                            (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["optionMultiLabelMaxLines"] as? [String: Any] ?? [:]
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
                                    ) ["optionMultiSecondaryLabelMaxLines"] as? [String: Any] ?? [:]
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
                .foregroundColor(isChecked ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["chip"] as? [String: Any] ?? [:]
                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["optionMultiToggleCheckedContentColor"] as? [String: Any] ?? [:]
                                                              ) ["stringValue"] as! String
                                                  ) : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                                       ) ["chip"] as? [String: Any] ?? [:]
                                                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                       ) ["fields"] as? [String: Any] ?? [:]
                                                                       ) ["optionMultiToggleUncheckedContentColor"] as? [String: Any] ?? [:]
                                                                       ) ["stringValue"] as! String
                                                           )
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
                    view.padding(.vertical, 6)
                }
                Spacer()
                Image(systemName: isChecked ? "checkmark.square" : "square")
                    .foregroundColor(
                        isChecked ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                      ) ["chip"] as? [String: Any] ?? [:]
                                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                                      ) ["optionMultiToggleCheckedContentColor"] as? [String: Any] ?? [:]
                                                                      ) ["stringValue"] as! String
                                                          ) : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                                               ) ["chip"] as? [String: Any] ?? [:]
                                                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                                               ) ["optionMultiToggleUncheckedContentColor"] as? [String: Any] ?? [:]
                                                                               ) ["stringValue"] as! String
                                                                   )
                    )
            }
            .ifMorePaddingNeeded { view in
                view.padding(.horizontal, 16)
            }
            .background(
                (isUnavailable || !hasSatisfiedTimeCriteria)
                ? LinearGradient(gradient: Gradient(colors: [Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["chip"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["optionChipGrayedOutBackgroundColor"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as! String),
                                                           Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["chip"] as? [String: Any] ?? [:]
                                                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["optionChipGrayedOutBackgroundColor"] as? [String: Any] ?? [:]
                                                                            ) ["stringValue"] as! String
                                                                )]), startPoint: .leading, endPoint: .trailing)
                : isChecked ?
                LinearGradient(gradient: Gradient(colors: [Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["chip"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["optionMultiToggleCheckedStartBackgroundColor"] as? [String: Any] ?? [:]
                                                                           ) ["stringValue"] as! String),
                                                           Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["chip"] as? [String: Any] ?? [:]
                                                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["optionMultiToggleCheckedEndBackgroundColor"] as? [String: Any] ?? [:]
                                                                            ) ["stringValue"] as! String
                                                                )]), startPoint: .leading, endPoint: .trailing)
                :
                LinearGradient(gradient: Gradient(colors: [Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["chip"] as? [String: Any] ?? [:]
                                                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["optionMultiToggleUncheckedStartBackgroundColor"] as? [String: Any] ?? [:]
                                                                            ) ["stringValue"] as! String
                                                                ),
                                                           Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["chip"] as? [String: Any] ?? [:]
                                                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                            ) ["fields"] as? [String: Any] ?? [:]
                                                                            ) ["optionMultiToggleUncheckedEndBackgroundColor"] as? [String: Any] ?? [:]
                                                                            ) ["stringValue"] as! String
                                                                )]), startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
            .onAppear(perform: {
                if (!isIntermediateButton) {
                    self.viewModel.isAllOptionSelectionsSuccessful = true
                }
            })
    }
}

