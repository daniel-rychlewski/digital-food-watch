import SwiftUI

struct FoodActivity: View {
    @State private var count: Int = 0
    @State private var showingOptions = false
    @ObservedObject var viewModel: FoodActivityModel
    
    init(id: String,
         name: String,
         nameEn: String,
         description: String,
         descriptionEn: String,
         isCategory: Bool,
         numberOfOptions: Int,
         useInternationalNames: Bool) {

        viewModel = FoodActivityModel()
        viewModel.configure(
            id: id,
            name: name,
            nameEn: nameEn,
            description: description,
            descriptionEn: descriptionEn,
            isCategory: isCategory,
            numberOfOptions: numberOfOptions,
            useInternationalNames: useInternationalNames)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(viewModel.name)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(viewModel.description)
                    .font(.system(size: 14))
                    .padding(.top, 4)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(alignment: .center) {
                    Button(action: {
                        viewModel.decrement(count: &count, id: Int(viewModel.id)!, options: viewModel.numberOfOptions)
                    }) {
                        Text("-")
                            .frame(width: CGFloat(Constants.UI.foodButtonWidth), height: CGFloat(Constants.UI.foodButtonHeight))
                            .background(
                                Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["food"] as? [String: Any] ?? [:]
                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["minusButtonBackgroundColor"] as? [String: Any] ?? [:]
                                                  ) ["stringValue"] as! String)
                            )
                            .foregroundColor(
                                Color(hex: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["food"] as? [String: Any] ?? [:]
                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["minusButtonContentColor"] as? [String: Any] ?? [:]
                                                   ) ["stringValue"] as! String))
                            )
                            .clipShape(Circle())
                    }
                    .frame(width: CGFloat(Constants.UI.foodButtonWidth), height: CGFloat(Constants.UI.foodButtonWidth))
                    .clipShape(Circle())
                    .disabled(count <= 0)
                    .opacity(count <= 0 ? 0.4 : 1.0)
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.system(size: 30))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.isAllOptionSelectionsSuccessful = nil // reset so that another 1x of the product can be selected
                        viewModel.increment(showingOptions: &showingOptions, count: &count, id: Int(viewModel.id)!, options: viewModel.numberOfOptions)
                    }) {
                        Text("+")
                            .frame(width: CGFloat(Constants.UI.foodButtonWidth), height: CGFloat(Constants.UI.foodButtonHeight))
                            .background(
                                Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["food"] as? [String: Any] ?? [:]
                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["plusButtonBackgroundColor"] as? [String: Any] ?? [:]
                                                  ) ["stringValue"] as! String)
                            )
                            .foregroundColor(
                                Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["food"] as? [String: Any] ?? [:]
                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["plusButtonContentColor"] as? [String: Any] ?? [:]
                                                  ) ["stringValue"] as! String)
                            )
                            .clipShape(Circle())
                    }
                    .frame(width: CGFloat(Constants.UI.foodButtonWidth), height: CGFloat(Constants.UI.foodButtonWidth))
                    .clipShape(Circle())
                    .sheet(isPresented: $showingOptions) {
                        OptionActivity(id: viewModel.id, optionScreenNumber: 0, useInternationalNames: viewModel.useInternationalNames, count: $count, viewModel: viewModel)
                    }
                }
                .padding(.top, 8)
                .frame(maxWidth: .infinity)
            }
            .onAppear(perform: updateDisplayedQuantity)
        }
    }

    private func updateDisplayedQuantity() {
        count = DataHolder.cart[Int(viewModel.id) ?? 0] ?? 0
    }
}
