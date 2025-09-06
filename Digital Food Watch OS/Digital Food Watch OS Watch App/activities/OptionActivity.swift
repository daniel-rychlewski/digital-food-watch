import SwiftUI

struct OptionActivity: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss

    @State private var isNavigationActive = false

    @State private var previousOptionId: Int?
    @State private var selectedOptionId: Int?
    @State private var selectedMultiOptions: [Int] = []
    
    @Binding var count: Int
    
    @ObservedObject var viewModel: FoodActivityModel

    var id: String
    var optionScreenNumber: Int
    var useInternationalNames: Bool = false
    
    init(id: String,
         optionScreenNumber: Int,
         useInternationalNames: Bool,
         count: Binding<Int>,
         viewModel: FoodActivityModel) {
        
        self.id = id
        self.optionScreenNumber = optionScreenNumber
        self.useInternationalNames = useInternationalNames
        self._count = count
        self.viewModel = viewModel
    }
    
    var body: some View {
        let foodOptions = DataHolder.food.first { $0.id == Int(self.id) }?.options?.options as? [Option]
        let foodOpt = foodOptions?[optionScreenNumber]
        let config = foodOpt!.config as Config
        let content = foodOpt!.content as [OptionContent]
        let mode = config.mode as String // single or multi
        let name = config.name as String
        let nameEn = config.nameEn ?? nil
        let titleHasImage = config.hasImage ?? false
        let titleBackgroundPath = config.background ?? nil
        
        let titleBackgroundBitmap: Image? = (titleBackgroundPath != nil) ? Image(titleBackgroundPath!) : nil
        
        var isIntermediateButton: Bool = self.optionScreenNumber + 1 < foodOptions?.count ?? 0
        var isFirstOption: Bool = optionScreenNumber == 0
        
        return NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        OptionChip(
                            parentId: 0,
                            id: 0,
                            name: name,
                            nameEn: nameEn ?? "",
                            price: nil,
                            bitmapImage: nil,
                            useInternationalNames: useInternationalNames,
                            isFirstOption: isFirstOption,
                            isIntermediateButton: isIntermediateButton,
                            availableFrom: nil,
                            availableTo: nil,
                            hasSatisfiedTimeCriteria: true,
                            isUnavailable: false,
                            isSelected: Binding<Bool>(get: { false }, set: { if $0 { false } }),
                            previousOptionId: Binding<Int?>(get: { nil }, set: { if false { $0 } }),
                            viewModel: viewModel
                        )

                        if isIntermediateButton {
                            // If not the last option screen, navigate to the next one.
                            NavigationLink(
                                destination: OptionActivity(
                                    id: self.id,
                                    optionScreenNumber: self.optionScreenNumber + 1,
                                    useInternationalNames: self.useInternationalNames,
                                    count: $count,
                                    viewModel: viewModel
                                ),
                                label: {
                                    getNextButton(text: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) ["chip"] as? [String: Any] ?? [:]
                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                              ) [DataHolder.internationalizeLabel(labelName: "optionNextButtonText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                              ) ["stringValue"] as! String)
                                }
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
                            .background(mode == "single" && selectedOptionId == nil ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                                 ) ["chip"] as? [String: Any] ?? [:]
                                                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                                 ) ["optionChipBackgroundColor"] as? [String: Any] ?? [:]
                                                                                                 ) ["stringValue"] as! String
                                                                                                 )
                                        : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                                              ) ["chip"] as? [String: Any] ?? [:]
                                                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                                              ) ["optionNextButtonSelectedBackgroundColor"] as? [String: Any] ?? [:]
                                                                              ) ["stringValue"] as! String))
                            .cornerRadius(CGFloat(Constants.UI.chipCornerRadius))
                            .disabled(mode == "single" && selectedOptionId == nil)
                        }
                    }
                    
                    ForEach(content.indices, id: \.self) { index in
                        let optionEntry = content[index]
                        if let optionId = optionEntry.id as Int? {
                            let optionName = optionEntry.name
                            let optionNameEn = optionEntry.nameEn ?? ""
                            let optionPrice = optionEntry.price ?? 0.0
                            let optionHasImage = optionEntry.hasImage ?? false
                            let optionBackgroundPath = optionEntry.background ?? ""
                            let availableFrom = optionEntry.availableFrom ?? ""
                            let availableTo = optionEntry.availableTo ?? ""
                            
                            let price = DataHolder.formatPrice(price: optionPrice)
                            let backgroundBitmap: Image? = (optionBackgroundPath != nil) ? Image(optionBackgroundPath) : nil

                            let optionId = optionEntry.id as Int?
                            
                            if (mode as String == "single") {
                                OptionChip(
                                    parentId: Int(self.id) ?? 0,
                                    id: optionId,
                                    name: optionName,
                                    nameEn: optionNameEn,
                                    price: price,
                                    bitmapImage: (optionHasImage == true) ? backgroundBitmap : nil,
                                    useInternationalNames: useInternationalNames,
                                    isFirstOption: isFirstOption,
                                    isIntermediateButton: isIntermediateButton,
                                    availableFrom: availableFrom,
                                    availableTo: availableTo,
                                    hasSatisfiedTimeCriteria: satisfiesTimeCriteria(availableFrom: availableFrom, availableTo: availableTo, fallbackForInvalidTime: true),
                                    isUnavailable: isUnavailable(availableFrom: availableFrom, availableTo: availableTo),
                                    isSelected: Binding<Bool>(get: { selectedOptionId == optionId }, set: { if $0 { selectedOptionId = optionId } }),
                                    previousOptionId: Binding<Int?>(get: { previousOptionId }, set: { previousOptionId = $0 }),
                                    viewModel: viewModel
                                )
                            } else if (mode as String == "multi") {
                                OptionMultiChip(
                                    parentId: Int(self.id) ?? 0,
                                    id: optionId,
                                    name: optionName,
                                    nameEn: optionNameEn,
                                    price: price,
                                    useInternationalNames: useInternationalNames,
                                    isFirstOption: isFirstOption,
                                    isIntermediateButton: isIntermediateButton,
                                    availableFrom: availableFrom,
                                    availableTo: availableTo,
                                    hasSatisfiedTimeCriteria: satisfiesTimeCriteria(availableFrom: availableFrom, availableTo: availableTo, fallbackForInvalidTime: true),
                                    isUnavailable: isUnavailable(availableFrom: availableFrom, availableTo: availableTo),
                                    isSelected: Binding<Bool>(
                                        get: {
                                            if (optionId != nil) {
                                                return selectedMultiOptions.contains(optionId!)
                                            } else {
                                                return false
                                            }
                                        },
                                        set: { newValue in
                                            if newValue {
                                                if optionId != nil {
                                                    selectedMultiOptions.append(optionId!)
                                                }
                                            } else {
                                                selectedMultiOptions.removeAll(where: { $0 == optionId })
                                            }
                                        }
                                    ),
                                    selectedMultiOptions: $selectedMultiOptions,
                                    viewModel: viewModel
                                )
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            if (viewModel.isAllOptionSelectionsSuccessful == true) {
                self.dismiss()
            }
        })
        .onDisappear(perform: {
            // the rollback is only for the disappear if user clicks BACK, not for the disappear when user clicks NEXT => hence, use presentationMode.wrappedValue.isDismissing
            if (viewModel.isAllOptionSelectionsSuccessful == nil && !presentationMode.wrappedValue.isPresented) {
                // roll back
                if (mode == "single") {
                    if let selectedOptionId = self.selectedOptionId {
                        DataHolder.cart[selectedOptionId] = (DataHolder.cart[selectedOptionId] ?? 0) - 1
                        DataHolder.totalPrice = DataHolder.calculateCartPrice(cart: DataHolder.cart)
                        
                        var mapping = DataHolder.foodToOptionsMapping[Int(self.id) ?? 0]
                        if mapping != nil {
                            var mostRecentMapping = mapping![mapping!.count - 1]
                            if let index = mostRecentMapping.firstIndex(of: selectedOptionId) {
                                mostRecentMapping.remove(at: index)
                                DataHolder.foodToOptionsMapping[Int(self.id) ?? 0]!.removeLast()
                                DataHolder.foodToOptionsMapping[Int(self.id) ?? 0]!.insert(mostRecentMapping, at: mapping!.count - 1)
                            }
                        }
                    }
                } else if (mode == "multi") {
                    if (!selectedMultiOptions.isEmpty) {
                        for optionId in selectedMultiOptions {
                            DataHolder.cart[optionId] = (DataHolder.cart[optionId] ?? 0) - 1
                            DataHolder.totalPrice = DataHolder.calculateCartPrice(cart: DataHolder.cart)

                            let mapping = DataHolder.foodToOptionsMapping[Int(self.id) ?? 0]
                            if mapping != nil {
                                var mostRecentMapping = mapping![mapping!.count - 1]
                                if let index = mostRecentMapping.firstIndex(of: optionId) {
                                    mostRecentMapping.remove(at: index)
                                    DataHolder.foodToOptionsMapping[Int(self.id) ?? 0]!.removeLast()
                                    DataHolder.foodToOptionsMapping[Int(self.id) ?? 0]!.insert(mostRecentMapping, at: mapping!.count - 1)
                                }
                            }
                        }
                    }
                }
                
                if (isFirstOption) {
                    // the main product must be decreased by one as well, not just the options rolled back.
                    DataHolder.cart[Int(id) ?? 0] = (DataHolder.cart[Int(id) ?? 0] ?? 0) - 1
                    count = (DataHolder.cart[Int(id) ?? 0] ?? 0)
                    DataHolder.totalPrice = DataHolder.calculateCartPrice(cart: DataHolder.cart)
                }
            }

            if (!isIntermediateButton) {
                dismiss()
            }
        })
    }

    func getNextButton(text: String) -> some View {
        Text(text)
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
            .truncationMode(.tail)
            .attemptBold()
            .multilineTextAlignment(.leading)
            .font(.system(size: 15))
    }
}
