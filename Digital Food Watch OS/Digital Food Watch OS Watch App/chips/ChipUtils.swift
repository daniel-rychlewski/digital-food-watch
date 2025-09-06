import Foundation

func getAvailabilityRestrictions(availableFrom: String?, availableTo: String?, useInternationalNames: Bool, type: String) -> String {
    if let availableFrom = availableFrom, availableFrom != "" {
        if let availableTo = availableTo, availableTo != "" {
            return String(format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) ["chip"] as? [String: Any] ?? [:]
                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) [DataHolder.internationalizeLabel(labelName: type + "SecondaryLabelWithAvailabilityFromAndTo", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                        ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"), availableFrom, availableTo)
        } else {
            return String(format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) ["chip"] as? [String: Any] ?? [:]
                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) [DataHolder.internationalizeLabel(labelName: type + "SecondaryLabelWithAvailabilityFrom", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                        ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"), availableFrom)
        }
    } else {
        if let availableTo = availableTo, availableTo != "" {
            return String(format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) ["chip"] as? [String: Any] ?? [:]
                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) [DataHolder.internationalizeLabel(labelName: type + "SecondaryLabelWithAvailabilityTo", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                        ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"), availableTo)
        } else {
            return ""
        }
    }
}

func isUnavailable(availableFrom: String?, availableTo: String?) -> Bool {
    let notAvailable = (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["main"] as? [String: Any] ?? [:]
                              ) ["mapValue"] as? [String: Any]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["notAvailable"] as? [String: Any] ?? [:]
                              ) ["stringValue"] as! String)

    if availableFrom == notAvailable || availableTo == notAvailable {
        return true
    } else {
        return false
    }
}

func isWrongDay(daysAvailable: [[String: Any]]?, actualDay: String?) -> Bool {
    guard let daysAvailable = daysAvailable, let actualDay = actualDay else {
        return false
    }

    let dayStrings = daysAvailable.compactMap { $0["stringValue"] as? String }

    if !dayStrings.contains(actualDay) {
        return true
    } else {
        return false
    }
}

func getDaySpecificText(daysAvailable: [[String: Any]]?, actualDay: String?, useInternationalNames: Bool) -> String {
    guard let daysAvailable = daysAvailable, let actualDay = actualDay else { return "" }
    
    let dayStrings = daysAvailable.compactMap { $0["stringValue"] as? String }
    
    if !dayStrings.contains(actualDay) {
        
        let label = (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
            ) ["fields"] as? [String: Any] ?? [:]
            ) ["chip"] as? [String: Any] ?? [:]
            ) ["mapValue"] as? [String: Any]) ?? [:]
            ) ["fields"] as? [String: Any] ?? [:]
            ) [DataHolder.internationalizeLabel(labelName: "dayAvailability", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
            ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@")
        
        if dayStrings.isEmpty {
            return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                               ) ["main"] as? [String: Any] ?? [:]
                                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                               ) [DataHolder.internationalizeLabel(labelName: "notAvailableText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                               ) ["stringValue"] as! String
        } else if dayStrings.count == 1 {
            let dayName = DataHolder.toDayNames(days: dayStrings, useInternationalNames: useInternationalNames, useShort: false).first ?? ""
            return String(format: label, dayName)
        } else {
            let dayNames = DataHolder.toDayNames(days: dayStrings, useInternationalNames: useInternationalNames, useShort: true)
            let joinedDays = dayNames.joined(separator: ", ")
            return String(format: label, joinedDays)
        }
    }
    
    return "" // no day-specific restriction
}

func satisfiesTimeCriteria(availableFrom: String?, availableTo: String?, fallbackForInvalidTime: Bool) -> Bool {
    if availableFrom == nil && availableTo == nil { return fallbackForInvalidTime }

    var isFromTimeAvailable = true
    var isToTimeAvailable = true

    var fromHours = 0
    var fromMinutes = 0

    var toHours = 0
    var toMinutes = 0

    if let availableFrom = availableFrom, availableFrom != "" {
        let fromSplit = availableFrom.split(separator: ":")
        if fromSplit.count < 2 { return fallbackForInvalidTime }
        guard let fromHour = Int(fromSplit[0]),
              let fromMinute = Int(fromSplit[1]),
              fromHour >= 0 && fromHour <= 23 && fromMinute >= 0 && fromMinute <= 59 else {
            return fallbackForInvalidTime
        }
        fromHours = fromHour
        fromMinutes = fromMinute
    } else {
        isFromTimeAvailable = false
    }

    if let availableTo = availableTo, availableTo != "" {
        let toSplit = availableTo.split(separator: ":")
        if toSplit.count < 2 { return fallbackForInvalidTime }
        guard let toHour = Int(toSplit[0]),
              let toMinute = Int(toSplit[1]),
              toHour >= 0 && toHour <= 23 && toMinute >= 0 && toMinute <= 59 else {
            return fallbackForInvalidTime
        }
        toHours = toHour
        toMinutes = toMinute
    } else {
        isToTimeAvailable = false
    }

    let actualTime = Calendar.current.dateComponents([.hour, .minute], from: Date())

    if isFromTimeAvailable {
        var fromTimeComponents = DateComponents()
        fromTimeComponents.hour = fromHours
        fromTimeComponents.minute = fromMinutes
        fromTimeComponents.second = 0
        fromTimeComponents.nanosecond = 0

        guard let fromTime = Calendar.current.date(from: fromTimeComponents) else { return fallbackForInvalidTime }

        if isToTimeAvailable {
            var toTimeComponents = DateComponents()
            toTimeComponents.hour = toHours
            toTimeComponents.minute = toMinutes
            toTimeComponents.second = 0
            toTimeComponents.nanosecond = 0

            guard let toTime = Calendar.current.date(from: toTimeComponents) else { return fallbackForInvalidTime }
            
            let actualHour = actualTime.hour!
            let actualMinute = actualTime.minute!
            let toHour = toTimeComponents.hour!
            let toMinute = toTimeComponents.minute!

            let actualTotalMinutes = actualHour * 60 + actualMinute
            let toTotalMinutes = toHour * 60 + toMinute
            
            let actualDate = Calendar.current.date(from: actualTime)!

            return actualDate < toTime && (actualDate > fromTime || actualDate == fromTime)

        } else {
            let actualDate = Calendar.current.date(from: actualTime)!
            return (actualDate > fromTime || actualDate == fromTime) && fallbackForInvalidTime
        }

    } else {
        if isToTimeAvailable {
            var toTimeComponents = DateComponents()
            toTimeComponents.hour = toHours
            toTimeComponents.minute = toMinutes
            toTimeComponents.second = 0
            toTimeComponents.nanosecond = 0

            guard let toTime = Calendar.current.date(from: toTimeComponents) else { return fallbackForInvalidTime }

            let actualHour = actualTime.hour!
            let actualMinute = actualTime.minute!
            let toHour = toTimeComponents.hour!
            let toMinute = toTimeComponents.minute!
            
            let actualTotalMinutes = actualHour * 60 + actualMinute
            let toTotalMinutes = toHour * 60 + toMinute

            return actualTotalMinutes < toTotalMinutes && fallbackForInvalidTime

        } else {
            return fallbackForInvalidTime
        }
    }
}

func isRestaurantCurrentlyOpen() -> Bool {
    var calendar = Calendar.current
    calendar.locale = Locale(identifier: "en_US")
    let dayOfWeek = calendar.component(.weekday, from: Date())
    let dayOfWeekString = calendar.weekdaySymbols[dayOfWeek - 1].lowercased()

    if let timesForToday = ((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any] ?? [:]
                                  ) ["fields"] as? [String: Any] ?? [:]
                                  ) ["openingTimes"] as? [String: Any] ?? [:]
                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                  ) ["fields"] as? [String: Any] ?? [:]
                                  ) [dayOfWeekString] as? [String: Any] ?? [:]
                                  ) ["arrayValue"] as? [String: Any] ?? [:]
                                  ) ["values"] as? [[String: Any]] {

        var isOpeningTimeSatisfied = false

        for timeRangeWrapped in timesForToday {
            let timeRange = ((timeRangeWrapped["mapValue"] as? [String: Any]) ?? [:]) ["fields"] as? [String: Any] ?? [:]

            if let fromTime = ((timeRange["from"] as? [String: Any]) ?? [:])["stringValue"] as? String,
               let toTime = ((timeRange["to"] as? [String: Any]) ?? [:])["stringValue"] as? String,
               satisfiesTimeCriteria(availableFrom: fromTime, availableTo: toTime, fallbackForInvalidTime: false) {
               isOpeningTimeSatisfied = true
               break
            }
        }

        return isOpeningTimeSatisfied
    } else {
        return false
    }
}

func getMinimumOrderValuePrice() -> Double {
    guard let minimumOrderValueMap = ((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["minimumOrderMap"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] else {
        return Double.greatestFiniteMagnitude
    }

    if let zip = DataHolder.deliveryMode == "collection" ? "collection" : (DataHolder.deliveryMode == "dine-in" ? "dine-in" : DataHolder.zip),
       let minimumOrderValueLookupForZipCode = minimumOrderValueMap[zip] as? [String: Any],
       let value = (minimumOrderValueLookupForZipCode["integerValue"] as? Int).map(Double.init)
           ?? (minimumOrderValueLookupForZipCode["integerValue"] as? String).flatMap(Double.init)
           ?? minimumOrderValueLookupForZipCode["doubleValue"] as? Double {
        return value
    } else {
        return Double.greatestFiniteMagnitude
    }
}

func getMinimumOrderValueText(useInternationalNames: Bool) -> String {
    guard let minimumOrderValueMap = ((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["minimumOrderMap"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] else {
        if DataHolder.deliveryMode == "collection" {
            return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["chip"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "noCollectionPossible", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
        } else if DataHolder.deliveryMode == "dine-in" {
            return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["chip"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "noDineInPossible", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
        } else { // DataHolder.deliveryMode == "delivery"
            return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["chip"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "noDeliveryPossible", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
        }
    }
    
    if DataHolder.deliveryMode == "collection" {
        if let minimumOrderValueLookupForZipCode = minimumOrderValueMap["collection"] as? [String: Any],
           let value = (minimumOrderValueLookupForZipCode["integerValue"] as? Int).map(Double.init)
               ?? (minimumOrderValueLookupForZipCode["integerValue"] as? String).flatMap(Double.init)
               ?? minimumOrderValueLookupForZipCode["doubleValue"] as? Double {

            if (DataHolder.totalPrice == 0.0) {
                return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "addProducts", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
            } else {
                let formattedPrice = DataHolder.formatPrice(price: value)
                return String(format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "minimumOrderValue", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"), formattedPrice)
            }
        } else {
            return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "noCollectionPossible", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
        }
    } else if DataHolder.deliveryMode == "dine-in" {
        if let minimumOrderValueLookupForZipCode = minimumOrderValueMap["dine-in"] as? [String: Any],
           let value = (minimumOrderValueLookupForZipCode["integerValue"] as? Int).map(Double.init)
               ?? (minimumOrderValueLookupForZipCode["integerValue"] as? String).flatMap(Double.init)
               ?? minimumOrderValueLookupForZipCode["doubleValue"] as? Double {

            if (DataHolder.totalPrice == 0.0) {
                return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "addProducts", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
            } else {
                let formattedPrice = DataHolder.formatPrice(price: value)
                return String(format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "minimumOrderValue", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"), formattedPrice)
            }
        } else {
            return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "noDineInPossible", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
        }
    } else { // DataHolder.deliveryMode == "delivery"
        if let zip = DataHolder.zip,
           let minimumOrderValueLookupForZipCode = minimumOrderValueMap[zip] as? [String: Any],
           let value = (minimumOrderValueLookupForZipCode["integerValue"] as? Int).map(Double.init)
               ?? (minimumOrderValueLookupForZipCode["integerValue"] as? String).flatMap(Double.init)
               ?? minimumOrderValueLookupForZipCode["doubleValue"] as? Double {

            let formattedPrice = DataHolder.formatPrice(price: value)
            return String(format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "minimumOrderValue", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"), formattedPrice)
        } else if DataHolder.zip == nil {
            return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "enterContactData", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
        } else {
            return ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["chip"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "noDeliveryPossible", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
        }
    }
}
