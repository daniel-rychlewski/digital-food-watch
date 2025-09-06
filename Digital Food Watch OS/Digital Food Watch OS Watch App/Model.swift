import SwiftUI

struct Config {
    let mode: String
    let name: String
    let nameEn: String?
    let hasImage: Bool?
    let background: String?
}

struct Food {
    let id: Int
    let background: String?
    let name: String?
    let nameEn: String?
    let description: String?
    let descriptionEn: String?
    let hasImage: Bool?
    let isCategory: Bool?
    let price: Double?
    let options: Options?
    let availableFrom: String?
    let availableTo: String?
    let daysAvailable: [[String: Any]]?
    let isHidden: Bool?
}

struct Option {
    let config: Config
    let content: [OptionContent]
}

struct OptionContent {
    let id: Int
    let name: String
    let nameEn: String?
    let price: Double?
    let hasImage: Bool?
    let background: String?
    let availableFrom: String?
    let availableTo: String?
}

struct Options {
    let options: [Option]?
}

// every food has a FoodActivityModel
class FoodActivityModel: ObservableObject {
    @Published var id: String = ""
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var isCategory: Bool = false
    @Published var numberOfOptions: Int = 0
    @Published var useInternationalNames: Bool = false
    @Published var isAllOptionSelectionsSuccessful: Bool? = nil

    func configure(id: String,
                   name: String,
                   nameEn: String,
                   description: String,
                   descriptionEn: String,
                   isCategory: Bool,
                   numberOfOptions: Int,
                   useInternationalNames: Bool) {
        self.id = id
        self.name = useInternationalNames ? nameEn : name
        self.description = useInternationalNames ? descriptionEn : description
        self.isCategory = isCategory
        self.numberOfOptions = numberOfOptions
        self.useInternationalNames = useInternationalNames
    }
    
    func decrement(count: inout Int, id: Int, options: Int) {
        count -= 1
        DataHolder.cart[id] = count
        // If there are options, handle accordingly
        if numberOfOptions > 0 {
            // Check if mapping exists and it's not empty
            if var mapping = DataHolder.foodToOptionsMapping[id], !mapping.isEmpty {
                // Get the last sublist in the mapping
                if let lastSubList = mapping.last {
                    // Decrease the count of each item in the last sublist
                    for entry in lastSubList {
                        if var cartCount = DataHolder.cart[entry] {
                            cartCount -= 1
                            DataHolder.cart[entry] = cartCount
                        }
                    }
                    // Remove the last sublist
                    mapping.removeLast()
                    // Update the mapping
                    DataHolder.foodToOptionsMapping[id] = mapping
                }
            }
        }
        // Update total price
        DataHolder.totalPrice = DataHolder.calculateCartPrice(cart: DataHolder.cart)
    }

    func increment(showingOptions: inout Bool, count: inout Int, id: Int, options: Int) {
        count += 1
        if numberOfOptions > 0 {
            // Add another popup for user to choose the option
            showingOptions = true
        }
        DataHolder.cart[id] = count
        DataHolder.totalPrice = DataHolder.calculateCartPrice(cart: DataHolder.cart)
    }
}


