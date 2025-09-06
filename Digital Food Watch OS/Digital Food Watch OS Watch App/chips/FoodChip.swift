import SwiftUI

struct FoodChip: View {
    var id: Int
    var name: String?
    var nameEn: String?
    var description: String?
    var descriptionEn: String?
    var numberOfOptions: Int
    var price: String?
    var isCategory: Bool?
    var availableFrom: String?
    var availableTo: String?
    var bitmapImage: Image?
    var daysAvailable: [[String: Any]]?
    var actualDay: String
    var useInternationalNames: Bool

    var body: some View {
        let satisfiesTimeCriteria = satisfiesTimeCriteria(availableFrom: availableFrom, availableTo: availableTo, fallbackForInvalidTime: true)
        let isUnavailable: Bool = isUnavailable(availableFrom: availableFrom, availableTo: availableTo)
        let isWrongDay: Bool = isWrongDay(daysAvailable: daysAvailable, actualDay: actualDay)
                
        VStack(spacing: 20) {
            NavigationLink(destination: FoodActivity(
                id: String(id),
                name: name ?? "",
                nameEn: nameEn ?? "",
                description: description ?? "",
                descriptionEn: descriptionEn ?? "",
                isCategory: isCategory ?? false,
                numberOfOptions: numberOfOptions,
                useInternationalNames: useInternationalNames
            )) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(useInternationalNames ? (nameEn ?? "") : (name ?? ""))
                        .foregroundColor(
                            bitmapImage != nil ? Color.white : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                ) ["fields"] as? [String: Any] ?? [:]
                                                                ) ["chip"] as? [String: Any] ?? [:]
                                                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                ) ["fields"] as? [String: Any] ?? [:]
                                                                ) ["foodChipContentColor"] as? [String: Any] ?? [:]
                                                                ) ["stringValue"] as! String))
                        .attemptBold()
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 15))
                    if !isUnavailable && !isWrongDay {
                        if price != nil {
                            Text(price! + getAvailabilityRestrictions(availableFrom: availableFrom, availableTo: availableTo, useInternationalNames: useInternationalNames, type: "food"))
                                .foregroundColor(
                                    bitmapImage != nil ? Color.white : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                                    ) ["chip"] as? [String: Any] ?? [:]
                                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                                    ) ["foodChipContentColor"] as? [String: Any] ?? [:]
                                                                    ) ["stringValue"] as! String))
                                .font(.system(size: 15))
                        }
                    } else if (isWrongDay) {
                        Text(getDaySpecificText(daysAvailable: daysAvailable, actualDay: actualDay, useInternationalNames: useInternationalNames))
                            .foregroundColor(
                                bitmapImage != nil ? Color.white : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) ["chip"] as? [String: Any] ?? [:]
                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) ["foodChipContentColor"] as? [String: Any] ?? [:]
                                                        ) ["stringValue"] as! String))
                            .font(.system(size: 15))
                    } else {
                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["main"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "notAvailableText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                            .foregroundColor(
                                bitmapImage != nil ? Color.white : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) ["chip"] as? [String: Any] ?? [:]
                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) ["foodChipContentColor"] as? [String: Any] ?? [:]
                                                        ) ["stringValue"] as! String))
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
                        ),
                       alignment: .leading
                )
                .foregroundColor(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                    ) ["chip"] as? [String: Any] ?? [:]
                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                    ) ["foodChipContentColor"] as? [String: Any] ?? [:]
                                                    ) ["stringValue"] as! String))
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
            .disabled(isCategory == true || !satisfiesTimeCriteria || isUnavailable || isWrongDay)
            .ifMorePaddingNeeded { view in
                view.padding(.horizontal, 16)
            }
        }
        .background(
            ZStack {
                if let bitmap = bitmapImage {
                    bitmap
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(Color.black.opacity(0.6))
                } else {
                    RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous)
                        .fill((satisfiesTimeCriteria && !isUnavailable && !isWrongDay) ?
                              Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["chip"] as? [String: Any] ?? [:]
                                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["foodChipBackgroundColor"] as? [String: Any] ?? [:]
                                                ) ["stringValue"] as! String)
                              : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["chip"] as? [String: Any] ?? [:]
                                                ) ["mapValue"] as? [String: Any]) ?? [:]
                                                ) ["fields"] as? [String: Any] ?? [:]
                                                ) ["foodChipGrayedOutBackgroundColor"] as? [String: Any] ?? [:]
                                                ) ["stringValue"] as! String))
                }
            }
        )
        .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
    }
}
