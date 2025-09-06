import SwiftUI

struct RestaurantClosedError: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                Text(String(localized: "restaurantClosedHeading"))
                    .font(.system(size: 17))
                
                VStack(alignment: .leading) {
                    Text(String(localized: "restaurantClosedOpeningTimes"))
                        .font(.system(size: 11))
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    
                    ForEach(openingTimes(), id: \.self) { time in
                        Text(time)
                            .font(.system(size: 10))
                            .padding(.bottom, 4)
                    }
                }
            }
        }
    }

    func openingTimes() -> [String] {
        let daysOfWeek = String(localized: "restaurantClosedDaysOfWeek").components(separatedBy: ",")

        let bundle = Bundle(path: Bundle.main.path(forResource: "en", ofType: "lproj")!)!
        let internationalDays = NSLocalizedString("restaurantClosedDaysOfWeek", bundle: bundle, comment: "").components(separatedBy: ",")

        var openingTimesText = ""
        for (index, day) in daysOfWeek.enumerated() {
            openingTimesText += generateOpeningTimes(day: day, internationalDay: internationalDays[index])
        }
        
        return openingTimesText.split(separator: "\n").map { String($0) }
    }

    func generateOpeningTimes(day: String, internationalDay: String) -> String {
        var result = day + ": "
        guard let times = ((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any] ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["openingTimes"] as? [String: Any] ?? [:]
                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) [internationalDay.lowercased()] as? [String: Any] ?? [:]
                                                   ) ["arrayValue"] as? [String: Any] ?? [:]
                                                   ) ["values"] as? [[String: Any]]

        else {
            return result + String(localized: "restaurantClosedTextForClosed") + "\n"
        }

        if times.isEmpty {
            return result + String(localized: "restaurantClosedTextForClosed") + "\n"
        } else {
            for (index, timeWrapped) in times.enumerated() {
                let time = (timeWrapped["mapValue"] as? [String: Any] ?? [:]) ["fields"] as? [String: Any] ?? [:]
                
                if let from = (time["from"] as? [String: Any])?["stringValue"] as? String,
                   let to = (time["to"] as? [String: Any])?["stringValue"] as? String {
                    
                    result += from + " - " + to
                    if index != times.count - 1 {
                        result += ", "
                    } else {
                        result += "\n"
                    }
                }
            }
        }
        return result
    }
}
