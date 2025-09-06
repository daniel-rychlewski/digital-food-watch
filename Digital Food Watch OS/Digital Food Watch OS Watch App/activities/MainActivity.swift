import SwiftUI
import Foundation
import Combine

struct MainActivity: View {
    var useInternationalNames: Bool
    let actualDay: String
    
    init(useInternationalNames: Bool) {
        self.useInternationalNames = useInternationalNames
        
        let actualTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE" // Full day name
        
        self.actualDay = dateFormatter.string(from: actualTime).lowercased()
    }
    
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack {
                            CartChip(totalPrice: DataHolder.totalPrice, useInternationalNames: useInternationalNames).id(0)
                            AddressChip(useInternationalNames: useInternationalNames)
                            ModeChip(useInternationalNames: useInternationalNames)
                            if (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                       ) ["fields"] as? [String: Any] ?? [:]
                                       ) ["main"] as? [String: Any] ?? [:]
                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                       ) ["fields"] as? [String: Any] ?? [:]
                                       ) ["enableFoodChip"] as? [String: Any] ?? [:]
                                       ) ["booleanValue"] as! Bool
                            ) {
                                FoodOverviewChip(useInternationalNames: useInternationalNames)
                            }
                            
                            ForEach(0..<DataHolder.food.count, id: \.self) { index in
                                
                                let foodItem = DataHolder.food[index]
                                
                                if (foodItem.isHidden != true) {
                                    let backgroundBitmap: Image? = (foodItem.background != nil) ? Image(foodItem.background!) : nil
                                    
                                    FoodChip(
                                        id: foodItem.id,
                                        name: foodItem.name,
                                        nameEn: foodItem.nameEn,
                                        description: foodItem.description,
                                        descriptionEn: foodItem.descriptionEn,
                                        numberOfOptions: foodItem.options?.options?.count ?? 0,
                                        price: (foodItem.price != nil && foodItem.price != 0.0) ? DataHolder.formatPrice(price: foodItem.price!) : nil,
                                        isCategory: foodItem.isCategory,
                                        availableFrom: foodItem.availableFrom,
                                        availableTo: foodItem.availableTo,
                                        bitmapImage: backgroundBitmap,
                                        daysAvailable: foodItem.daysAvailable,
                                        actualDay: actualDay,
                                        useInternationalNames: useInternationalNames
                                    )
                                }
                                
                            }
                            
                            TermsOfUseChip(useInternationalNames: useInternationalNames)
                            if (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                       ) ["fields"] as? [String: Any] ?? [:]
                                       ) ["main"] as? [String: Any] ?? [:]
                                       ) ["mapValue"] as? [String: Any]) ?? [:]
                                       ) ["fields"] as? [String: Any] ?? [:]
                                       ) ["enableImprintChip"] as? [String: Any] ?? [:]
                                       ) ["booleanValue"] as! Bool
                            ) {
                                ImprintChip(useInternationalNames: useInternationalNames)
                            }
                        }
                    }

                    Button(action: {
                        withAnimation {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }) {
                        Image(systemName: "chevron.up")
                            .font(.system(.title3))
                            .foregroundColor(
                                Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                 ) ["main"] as? [String: Any] ?? [:]
                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                 ) ["goUpTintColor"] as? [String: Any] ?? [:]
                                                 ) ["stringValue"] as! String)
                            )
                    }
                    .frame(width: CGFloat(Int(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                         ) ["fields"] as? [String: Any] ?? [:]
                                         ) ["main"] as? [String: Any] ?? [:]
                                         ) ["mapValue"] as? [String: Any]) ?? [:]
                                         ) ["fields"] as? [String: Any] ?? [:]
                                         ) ["goUpSize"] as? [String: Any] ?? [:]
                                         ) ["integerValue"] as? String ?? "35")!),
                           height: CGFloat(Int(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                 ) ["main"] as? [String: Any] ?? [:]
                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                 ) ["goUpSize"] as? [String: Any] ?? [:]
                                                 ) ["integerValue"] as? String ?? "35")!)
                    )
                    .background(
                        Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                         ) ["fields"] as? [String: Any] ?? [:]
                                         ) ["main"] as? [String: Any] ?? [:]
                                         ) ["mapValue"] as? [String: Any]) ?? [:]
                                         ) ["fields"] as? [String: Any] ?? [:]
                                         ) ["goUpColor"] as? [String: Any] ?? [:]
                                         ) ["stringValue"] as! String)
                    )
                    .clipShape(Circle())
                    .padding(.bottom, CGFloat(Constants.UI.goUpButtonBottomPadding))
                }
            }
        }
    }
    
    func base64ToImage(base64String: String) -> Image? {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }
}
