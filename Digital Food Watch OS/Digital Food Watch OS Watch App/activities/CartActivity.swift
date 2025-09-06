import SwiftUI
import Foundation
import Combine
import SwiftSoup
import OrderedCollections
import AuthenticationServices

struct CartActivity : View {
    var useInternationalNames: Bool
    
    @State var isOrderButtonEnabled: Bool = true
    @State private var isEnableCardPaymentCheckboxTicked: Bool = false
    @State private var isEnableCryptoPaymentCheckboxTicked: Bool = false

    @State private var showingSuccessAlert = false
    @State private var showingFailureAlert = false
    @State private var showingClosedAlert = false

    @State private var isSent = false
    
    @State private var conversionRate: Double = 1.0 // X USD = conversionRate * X USDC
    
    private var randomOrderNumber: String = String((0..<Int64(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["cart"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["sourceCharsetLength"] as? [String: Any] ?? [:]
                                                                           ) ["integerValue"] as! String ?? "0")!).map { _ in (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                     ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                     ) ["cart"] as? [String: Any] ?? [:]
                                                                                                                                     ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                                                                     ) ["fields"] as? [String: Any] ?? [:]
                                                                                                                                     ) ["sourceCharset"] as? [String: Any] ?? [:]
                                                                                                                                     ) ["stringValue"] as? String ?? "").randomElement() ?? Character("") })
    
    init(useInternationalNames: Bool) {
        self.useInternationalNames = useInternationalNames
    }

    var body: some View {
        
        let orderedItemsAmount = DataHolder.cart.values.filter { $0 > 0 }.reduce(0, +)
        var deliveryModeSelected = ""

        if let modeOptions = (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
            ) ["fields"] as? [String: Any] ?? [:]
            ) ["mode"] as? [String: Any] ?? [:]
            ) ["mapValue"] as? [String: Any]) ?? [:]
            ) ["fields"] as? [String: Any] ?? [:]
            ) ["modeOptions"] as? [String: Any] ?? [:]
            ) ["arrayValue"] as? [String: Any] ?? [:]
            ) ["values"] as? [[String: Any]] {
            for map in modeOptions {
                for (_, value) in map {
                    if DataHolder.deliveryMode == (((value as? [String: Any] ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["id"] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String {
                        
                        deliveryModeSelected = ((((((map as? [String: Any] ?? [:])
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "text", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
                    }
                }
            }
        }

        var totalPrice = (DataHolder.deliveryMode == "delivery")
            ? (Double(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                   ) ["fields"] as? [String: Any] ?? [:]
                   ) ["deliveryFees"] as? [String: Any] ?? [:]
                   ) ["mapValue"] as? [String: Any]) ?? [:]
                   ) ["fields"] as? [String: Any] ?? [:]
                   ) [DataHolder.zip ?? ""] as? [String: Any] ?? ["stringValue" : "0.0"]
                   ) ["stringValue"] as? String ?? "") ?? 0.0)
            : 0.0
        
        var foodOverview = ""
        
        DataHolder.reorderCart()
        
        // step 1/2: process cart elements to extract data for view
        var amounts = [] as [Int]
        var foodNames = [] as [String]
        var pricesFormatted = [] as [String]
        var isMainFoods = [] as [Bool]
        processForView(amounts: &amounts,
                       foodNames: &foodNames,
                       pricesFormatted: &pricesFormatted,
                       isMainFoods: &isMainFoods,
                       foodOverview: &foodOverview,
                       totalPrice: &totalPrice,
                       useInternationalNames: useInternationalNames)
        foodOverview +=
                    "    <tr>\n" +
                    "                        <td colspan=\"7\"></td>\n" +
                    "                    </tr>"

        var summarySection: String = "<tr>\n" +
                "        <td>\n" +
                "            <table style=\"margin-right:0;margin-left:auto;\">\n" +
                "                <tbody>"
        
        let deliveryFeeName: String = ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["cart"] as? [String: Any] ?? [:]
                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) [DataHolder.internationalizeLabel(labelName: "deliveryFeeTitle", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                            ) ["stringValue"] as! String
        let currency = ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) ["currency"] as? [String: Any] ?? [:]
                         ) ["stringValue"] as! String

        let deliveryFeeFormatted: String = DataHolder.formatPrice(price: Double(((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) ["deliveryFees"] as? [String: Any] ?? [:]
                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) [DataHolder.zip ?? ""] as? [String: Any] ?? ["stringValue" : "0.0"]
                                        ) ["stringValue"] as! String)!, includeCurrency: false)

        let paymentOptionsDelivery = ((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                       ) ["fields"] as? [String: Any] ?? [:]
                       ) [DataHolder.internationalizeLabel(labelName: "paymentOptionsDelivery", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                       ) ["arrayValue"] as? [String: Any] ?? [:]
                       ) ["values"] as? [[String: Any]]) ?? [[:]]

        var deliveryPaymentOptionsArray: [String] = []

        if !paymentOptionsDelivery.isEmpty {
            for option in paymentOptionsDelivery {
                if let time = option["stringValue"] as? String {
                    deliveryPaymentOptionsArray.append(time)
                }
            }
        }

        let deliveryPaymentOptions = deliveryPaymentOptionsArray.joined(separator: ", ")

        let paymentOptionsCollection = ((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                       ) ["fields"] as? [String: Any] ?? [:]
                       ) [DataHolder.internationalizeLabel(labelName: "paymentOptionsCollection", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                       ) ["arrayValue"] as? [String: Any] ?? [:]
                       ) ["values"] as? [[String: Any]]) ?? [[:]]

        var collectionPaymentOptionsArray: [String] = []

        if !paymentOptionsCollection.isEmpty {
            for option in paymentOptionsCollection {
                if let time = option["stringValue"] as? String {
                    collectionPaymentOptionsArray.append(time)
                }
            }
        }

        let collectionPaymentOptions = collectionPaymentOptionsArray.joined(separator: ", ")
        
        let paymentOptionsDineIn = ((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                       ) ["fields"] as? [String: Any] ?? [:]
                       ) [DataHolder.internationalizeLabel(labelName: "paymentOptionsDineIn", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                       ) ["arrayValue"] as? [String: Any] ?? [:]
                       ) ["values"] as? [[String: Any]]) ?? [[:]]

        var dineInPaymentOptionsArray: [String] = []

        if !paymentOptionsDineIn.isEmpty {
            for option in paymentOptionsDineIn {
                if let time = option["stringValue"] as? String {
                    dineInPaymentOptionsArray.append(time)
                }
            }
        }

        let dineInPaymentOptions = dineInPaymentOptionsArray.joined(separator: ", ")

        let cartTotalInvoiceText: String = String(
            format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                          ) ["fields"] as? [String: Any] ?? [:]
                                          ) ["cart"] as? [String: Any] ?? [:]
                                          ) ["mapValue"] as? [String: Any]) ?? [:]
                                          ) ["fields"] as? [String: Any] ?? [:]
                      ) [DataHolder.internationalizeLabel(labelName: isEnableCryptoPaymentCheckboxTicked ? "cartTotalInvoiceExclGasText" : "cartTotalInvoiceText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                          ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"),
            ((((((((((DataHolder.global["fields"] as? [String: Any] ?? [:]
                     ) ["countries"] as? [String: Any] ?? [:]
                     ) ["mapValue"] as? [String: Any]) ?? [:]
                     ) ["fields"] as? [String: Any] ?? [:]
                     ) [Constants.Firebase.country] as? [String: Any] ?? [:]
                     ) ["mapValue"] as? [String: Any]) ?? [:]
                     ) ["fields"] as? [String: Any] ?? [:]
                     ) ["foodVat"] as? [String: Any] ?? [:]
                     ) ["stringValue"] as! String
        )
        let cartTotalSummaryText: String = ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) ["cart"] as? [String: Any] ?? [:]
                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) [DataHolder.internationalizeLabel(labelName: "cartTotalSummaryText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                        ) ["stringValue"] as! String
        let cartTotalSummaryExclGasText: String = ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) ["cart"] as? [String: Any] ?? [:]
                                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) [DataHolder.internationalizeLabel(labelName: "cartTotalSummaryExclGas", useInternationalNames: useInternationalNames) + "Text"] as? [String: Any] ?? [:]
                                                        ) ["stringValue"] as! String
        let cartTotalPrice: String = DataHolder.formatPrice(price: totalPrice, includeCurrency: false)
        
        if DataHolder.deliveryMode == "delivery" {
            summarySection += """
                <tr>
                    <td style="text-align:right;font-size:18px;">\(deliveryFeeName)</td>
                    <td style="text-align:right;font-size:18px;">\(deliveryFeeFormatted)</td>
                    <td style="text-align:right;font-size:18px;">\(currency)</td>
                </tr>
            """
        }
        
        let tableColumnSpacing: CGFloat = 10
        let cartPadding: CGFloat = 8

        let totalWidth = WKInterfaceDevice.current().screenBounds.width

        // the proportions are chosen so that a price like "123.45" in the rightmost column fits in a single line on SE 40mm, Series 8 41mm, Series 8 45mm and Ultra 49mm
        let centerColumn = (totalWidth - tableColumnSpacing) * 2 / 3 - 15
        let edgeColumnLeft = (totalWidth - tableColumnSpacing - centerColumn) * 3 / 10 - 3
        let edgeColumnRight = (totalWidth - tableColumnSpacing - centerColumn) * 7 / 10 + 12

        let currencyOfficial = ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) ["currencyOfficial"] as? [String: Any] ?? [:]
                         ) ["stringValue"] as! String

        var transactionFee = 0.0
        var cartTotalPriceWithTransactionFees: String = ""
        var totalPriceWithTransactionFees = totalPrice
        if isEnableCardPaymentCheckboxTicked {
            totalPriceWithTransactionFees = ceil((totalPrice * (1.0 / Double((((((((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["processingFees"] as? [String: Any] ?? [:]
                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["factor"] as? [String: Any] ?? [:]
                                                   ) ["doubleValue"] as? Double ?? 0.985)))
                                   + (((((((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["processingFees"] as? [String: Any] ?? [:]
                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                   ) ["addedAmount"] as? [String: Any] ?? [:]
                                                   ) ["doubleValue"] as? Double ?? 1.0)) / 1000 as Double) * 1000
            transactionFee = totalPriceWithTransactionFees - totalPrice
            cartTotalPriceWithTransactionFees = DataHolder.formatPrice(price: totalPriceWithTransactionFees, includeCurrency: false)
        }

        let transactionFeeName: String = ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["cart"] as? [String: Any] ?? [:]
                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) [DataHolder.internationalizeLabel(labelName: "transactionFeeTitle", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                            ) ["stringValue"] as! String

        let transactionFeeFormatted: String = DataHolder.formatPrice(price: transactionFee, includeCurrency: false)

        if isEnableCardPaymentCheckboxTicked {
            summarySection += "\n" +
                    "                    <tr>\n" +
                    "                        <td style=\"text-align:right;font-size:18px;\">"+transactionFeeName+"</td>\n" +
                    "                        <td style=\"text-align:right;font-size:18px;\">"+transactionFeeFormatted+"</td>\n" +
                    "                        <td style=\"text-align:right;font-size:18px;\">"+currency+"</td>\n" +
                    "                    </tr>"
        }

        summarySection += "\n" +
                "                    <tr>\n" +
                "                        <td style=\"text-align:right;font-weight:bold;font-size:18px;\">"+cartTotalInvoiceText+"</td>\n" +
                "                        <td style=\"text-align:right;font-weight:bold;font-size:18px;\">"+cartTotalPrice+"</td>\n" +
                "                        <td style=\"text-align:right;font-weight:bold;font-size:18px;\">"+currency+"</td>\n" +
                "                    </tr>"

        summarySection += "\n                </tbody>\n" +
                            "            </table>\n" +
                            "        </td>\n" +
                            "    </tr>\n" +
                            "    <tr>\n" +
                            "        <td>\n" +
                            "            <br>\n" +
                            "        </td>\n" +
                            "    </tr>"

        let orderNowButtonText: String = String(
            format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                               ) ["cart"] as? [String: Any] ?? [:]
                                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                               ) [DataHolder.internationalizeLabel(labelName: "cartOrderNow", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                               ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"),
            DataHolder.formatPrice(price: transactionFee != 0.0 ? totalPriceWithTransactionFees : totalPrice, includeCurrency: true)
        )

        let orderNowButtonExclGasText: String = String(
            format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                               ) ["cart"] as? [String: Any] ?? [:]
                                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                               ) [DataHolder.internationalizeLabel(labelName: "cartOrderNowExclGas", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                               ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"),
            DataHolder.formatPrice(price: transactionFee != 0.0 ? totalPriceWithTransactionFees : totalPrice, includeCurrency: true)
        )

        return ScrollView {
            VStack {
                VStack {
                    Text(
                        (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["cart"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "cartSummaryText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String)
                        .replacingOccurrences(of: "%s", with: useInternationalNames ? deliveryModeSelected.lowercased(with: Locale.current) : deliveryModeSelected)
                    )
                    .font(.system(size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    .padding(.trailing, cartPadding)

                    // step 2/2: with the extracted data, the view can be displayed
                    buildView(amounts: amounts,
                                  foodNames: foodNames,
                                  pricesFormatted: pricesFormatted,
                                  isMainFoods: isMainFoods,
                                  edgeColumnLeft: edgeColumnLeft,
                                  centerColumn: centerColumn,
                                  edgeColumnRight: edgeColumnRight)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                    .frame(height:
                            CGFloat(Double(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                  ) ["fields"] as? [String: Any] ?? [:]
                                  ) ["cart"] as? [String: Any] ?? [:]
                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                  ) ["fields"] as? [String: Any] ?? [:]
                                  ) ["deliveryFeePaddingTop"] as? [String: Any] ?? [:]
                                  ) ["integerValue"] as! String) ?? 0))

                if (DataHolder.deliveryMode == "delivery") {
                    HStack {
                        Text("")
                            .font(.system(size: 13))
                            .frame(width: edgeColumnLeft, alignment: .leading)

                        Text(deliveryFeeName)
                            .font(.system(size: 13))
                            .frame(width: centerColumn, alignment: .leading)

                        Text(deliveryFeeFormatted)
                            .font(.system(size: 13))
                            .frame(width: edgeColumnRight, alignment: .leading)
                    }
                    .padding(.top, 8)
                }

                if transactionFee != 0.0 {
                    HStack {
                        Text("")
                            .font(.system(size: 13))
                            .frame(width: edgeColumnLeft, alignment: .leading)

                        Text(transactionFeeName)
                            .font(.system(size: 13))
                            .frame(width: centerColumn, alignment: .leading)

                        Text(transactionFeeFormatted)
                            .font(.system(size: 13))
                            .frame(width: edgeColumnRight, alignment: .leading)
                    }
                    .padding(.top, 8)
                }

                HStack {
                    Text("\(orderedItemsAmount)")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: edgeColumnLeft, alignment: .leading)

                    Text(isEnableCryptoPaymentCheckboxTicked ? cartTotalSummaryExclGasText : cartTotalSummaryText)
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: centerColumn, alignment: .leading)

                    Text(transactionFee != 0.0 ? cartTotalPriceWithTransactionFees : cartTotalPrice)
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: edgeColumnRight, alignment: .leading)

                }
                .padding(.top, (DataHolder.deliveryMode == "delivery") ? 6 : 8)

                }

                if DataHolder.isCardPaymentSupported == true {
                    VStack {
                        Toggle(isOn: $isEnableCardPaymentCheckboxTicked) {
                            Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "useOnlinePayment", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        }
                        .padding(.trailing, cartPadding)
                        .onChange(of: isEnableCardPaymentCheckboxTicked) { newValue in
                            if DataHolder.isCryptoPaymentSupported == true && newValue {
                                isEnableCryptoPaymentCheckboxTicked = false
                            }
                        }
                    }
                    .padding(.top, 12)
                }

                if DataHolder.isCryptoPaymentSupported == true {
                    VStack {
                        Toggle(isOn: $isEnableCryptoPaymentCheckboxTicked) {
                            Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "useCryptoPayment", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        }
                        .padding(.trailing, cartPadding)
                        .onChange(of: isEnableCryptoPaymentCheckboxTicked) { newValue in
                            if DataHolder.isCardPaymentSupported == true && newValue {
                                isEnableCardPaymentCheckboxTicked = false
                            }
                        }
                    }
                    .padding(.top, 6)
                }

                if DataHolder.deliveryMode == "collection" {
                    VStack(alignment: .leading) {
                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "collectionAddress", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.top, 8)
                        .padding(.trailing, cartPadding)

                        Text((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["address1"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as? String ?? ""))
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["address2"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as? String ?? ""))
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["address3"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as? String ?? "")
                        )
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text("")

                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "yourDetails", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["cart"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) [DataHolder.internationalizeLabel(labelName: "name", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String) + DataHolder.name!)
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["cart"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) [DataHolder.internationalizeLabel(labelName: "email", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String) + (DataHolder.email ?? "")) // if WhatsApp confirmation used, email could be empty
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["cart"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) [DataHolder.internationalizeLabel(labelName: "phone", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String) + (DataHolder.phoneNumber ?? ""))
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text("")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading) {
                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "availablePaymentMethodsCollection", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                        Text(collectionPaymentOptions)
                            .font(.system(size: 13))
                            .padding(.trailing, cartPadding)

                        Text("")

                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "usualCollectionTime", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                    Text(((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "collectionTime", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String)
                            .font(.system(size: 13))
                            .padding(.trailing, cartPadding)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else if DataHolder.deliveryMode == "dine-in" {
                    VStack(alignment: .leading) {
                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "dineInAddress", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.top, 8)
                        .padding(.trailing, cartPadding)

                        Text((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["address1"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as? String ?? ""))
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["address2"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as? String ?? ""))
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["address3"] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as? String ?? "")
                        )
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text("")

                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "yourDetails", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["cart"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) [DataHolder.internationalizeLabel(labelName: "name", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String) + DataHolder.name!)
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["cart"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) [DataHolder.internationalizeLabel(labelName: "email", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String) + DataHolder.email!)
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) ["cart"] as? [String: Any] ?? [:]
                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                    ) ["fields"] as? [String: Any] ?? [:]
                                    ) [DataHolder.internationalizeLabel(labelName: "phone", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                    ) ["stringValue"] as! String) + DataHolder.phoneNumber!)
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text("")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading) {
                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "availablePaymentMethodsDineIn", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                        Text(dineInPaymentOptions)
                            .font(.system(size: 13))
                            .padding(.trailing, cartPadding)

                        Text("")

                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "usualDineInTime", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                    Text(((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "dineInTime", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String)
                            .font(.system(size: 13))
                            .padding(.trailing, cartPadding)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else if DataHolder.deliveryMode == "delivery" {
                    VStack(alignment: .leading) {
                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "deliveryAddress", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.top, 8)
                        .padding(.trailing, cartPadding)

                        Text(DataHolder.street! + "\n" + DataHolder.zip! + " " + DataHolder.city!)
                            .font(.system(size: 13))
                            .padding(.trailing, cartPadding)

                        Text("")

                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "yourDetails", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) ["cart"] as? [String: Any] ?? [:]
                         ) ["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) [DataHolder.internationalizeLabel(labelName: "name", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                         ) ["stringValue"] as! String) + DataHolder.name!)
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) ["cart"] as? [String: Any] ?? [:]
                         ) ["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) [DataHolder.internationalizeLabel(labelName: "email", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                         ) ["stringValue"] as! String) + DataHolder.email!)
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text((((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) ["cart"] as? [String: Any] ?? [:]
                         ) ["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) [DataHolder.internationalizeLabel(labelName: "phone", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                         ) ["stringValue"] as! String) + DataHolder.phoneNumber!)
                        .font(.system(size: 13))
                        .padding(.trailing, cartPadding)

                        Text("")

                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "availablePaymentMethodsDelivery", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                        Text(deliveryPaymentOptions)
                            .font(.system(size: 13))
                            .padding(.trailing, cartPadding)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading) {
                        Text("")

                        Text(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) ["cart"] as? [String: Any] ?? [:]
                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                   ) ["fields"] as? [String: Any] ?? [:]
                                   ) [DataHolder.internationalizeLabel(labelName: "usualDeliveryTime", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                   ) ["stringValue"] as! String)
                        .font(.system(size: 13))
                        .fontWeight(.bold)
                        .padding(.trailing, cartPadding)

                        Text(((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                               ) ["fields"] as? [String: Any] ?? [:]
                               ) [DataHolder.internationalizeLabel(labelName: "deliveryTime", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                               ) ["stringValue"] as! String)
                            .font(.system(size: 13))
                            .padding(.trailing, cartPadding)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack {
                    Text(String(format: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["cart"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) [DataHolder.internationalizeLabel(labelName: "termsOfUseConfirm", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String,
                                (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                          ) ["fields"] as? [String: Any] ?? [:]
                                                          ) ["cart"] as? [String: Any] ?? [:]
                                                          ) ["mapValue"] as? [String: Any]) ?? [:]
                                                          ) ["fields"] as? [String: Any] ?? [:]
                                                          ) [DataHolder.internationalizeLabel(labelName: "cartOrderNow", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                          ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@")))
                        .font(.system(size: 10))
                        .padding(.trailing, cartPadding)

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, CGFloat(Double(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                    ) ["cart"] as? [String: Any] ?? [:]
                                                    ) ["mapValue"] as? [String: Any]) ?? [:]
                                                    ) ["fields"] as? [String: Any] ?? [:]
                                                    ) ["termsOfUsePaddingTop"] as? [String: Any] ?? [:]
                                                    ) ["integerValue"] as! String) ?? 0))
                .padding(.bottom, CGFloat(Double(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["cart"] as? [String: Any] ?? [:]
                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["cartOrderNowPaddingTop"] as? [String: Any] ?? [:]
                                               ) ["integerValue"] as! String) ?? 0))

                VStack {
                    if isEnableCryptoPaymentCheckboxTicked == false {
                        Button(action: {
                            if isEnableCardPaymentCheckboxTicked == true {
                                DataHolder.getPaymentLink(unitAmount: String(Int(ceil(totalPriceWithTransactionFees * 100))), email: DataHolder.email!, currency: currencyOfficial, useInternationalNames: useInternationalNames) { paymentLinkResultUrl in
                                    if let paymentLinkResultUrl = paymentLinkResultUrl {
                                        guard let url = URL(string: paymentLinkResultUrl) else {
                                            return
                                        }

                                        // Source: https://www.reddit.com/r/apple/comments/rcn2h7/comment/hnwr8do/
                                        let session = ASWebAuthenticationSession(
                                            url: url,
                                            callbackURLScheme: nil
                                        ) { (callbackURL, error) in
                                            if error != nil {
                                                // For example, User clicked on X
                                                let secretKey = ((((((((((((DataHolder.stripeConfig["mapValue"]) ?? [:]
                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                 ) ["apiKey"] as? [String: Any] ?? [:]
                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                 ) [DataHolder.activeCardPaymentMode!] as? [String: Any] ?? [:]
                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                 ) ["secretKey"] as? [String: Any] ?? [:]
                                                                 ) ["stringValue"] as! String
                                            
                                                DataHolder.retrieveCheckoutSession(paymentLinkId: DataHolder.paymentLinkId!, secretKey: secretKey) { isPaymentSuccessful in
                                                    if isPaymentSuccessful {
                                                        handleOrderNowButtonClicked(deliveryModeSelected: deliveryModeSelected, foodOverview: foodOverview, summarySection: summarySection)
                                                    } else {
                                                        // User closed the browser without even attempting to do the payment -> no action necessary.
                                                    }
                                                }
                                                
                                                return
                                            }
                                        }

                                        // Makes the "Watch App Wants To Use example.com to Sign In" popup not show up
                                        session.prefersEphemeralWebBrowserSession = true

                                        session.start()
                                    }
                                }
                            } else {
                                handleOrderNowButtonClicked(deliveryModeSelected: deliveryModeSelected, foodOverview: foodOverview, summarySection: summarySection)
                            }
                        }) {
                            Text(orderNowButtonText)
                            .foregroundColor(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["cart"] as? [String: Any] ?? [:]
                                              ) ["mapValue"] as? [String: Any]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["cartOrderNowContentColor"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String))
                        }
                        .formatOrderNowButton(isOrderButtonEnabled: isOrderButtonEnabled,
                                          useInternationalNames: useInternationalNames,
                                          cartPadding: cartPadding,
                                          showingSuccessAlert: $showingSuccessAlert,
                                          showingFailureAlert: $showingFailureAlert,
                                          showingClosedAlert: $showingClosedAlert
                        )

                    } else {
                        
                        Button(action: {}) {
                            NavigationLink(destination: CryptoActivity(
                                useInternationalNames: useInternationalNames,
                                orderNumber: randomOrderNumber,
                                totalPriceWithTransactionFees: totalPriceWithTransactionFees,
                                onPaymentResult: {
                                    handleOrderNowButtonClicked(deliveryModeSelected: deliveryModeSelected, foodOverview: foodOverview, summarySection: summarySection)
                                })
                            ) {
                                Text(orderNowButtonExclGasText)
                                    .foregroundColor(Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                      ) ["cart"] as? [String: Any] ?? [:]
                                                      ) ["mapValue"] as? [String: Any]) ?? [:]
                                                      ) ["fields"] as? [String: Any] ?? [:]
                                                      ) ["cartOrderNowContentColor"] as? [String: Any] ?? [:]
                                                      ) ["stringValue"] as! String))
                            }
                        }
                        .formatOrderNowButton(isOrderButtonEnabled: isOrderButtonEnabled,
                                              useInternationalNames: useInternationalNames,
                                              cartPadding: cartPadding,
                                              showingSuccessAlert: $showingSuccessAlert,
                                              showingFailureAlert: $showingFailureAlert,
                                              showingClosedAlert: $showingClosedAlert
                        )
                    }
                    
                }
                .cornerRadius(CGFloat(Constants.UI.rectangleCornerRadius))
            }
            .padding(.leading, cartPadding)
        }
    }
    
    func handleOrderNowButtonClicked(deliveryModeSelected: String, foodOverview: String, summarySection: String) {
        var confirmationHtml = DataHolder.confirmationTemplate ?? ""
        isOrderButtonEnabled = false

        let isOpeningTimeSatisfied = isRestaurantCurrentlyOpen()
        if (isOpeningTimeSatisfied) {
            if (!Constants.Config.isProd) {
                let testEmailText = ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                             ) ["fields"] as? [String: Any] ?? [:]
                             ) ["cart"] as? [String: Any] ?? [:]
                             ) ["mapValue"] as? [String: Any]) ?? [:]
                             ) ["fields"] as? [String: Any] ?? [:]
                             ) [DataHolder.internationalizeLabel(labelName: "testEmailText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                             ) ["stringValue"] as? String ?? ""

                confirmationHtml = confirmationHtml.replacingOccurrences(of: "#test\n", with: """
                    <table style="width: 100.0%;font-family: Calibri , serif;">
                        <tbody>
                            <tr>
                                <td style="text-align: left;font-size: 22.0px;font-weight: bold;">\(testEmailText)</td>
                            </tr>
                            <tr>
                                <td>
                                    <hr>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    """
                )
            } else {
                confirmationHtml = confirmationHtml.replacingOccurrences(of: "#test\n",
                                                                         with: "")
            }

            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#restaurantAddress1",
                                                                     with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                             ) ["fields"] as? [String: Any] ?? [:]
                                                                             ) ["address1"] as? [String: Any] ?? [:]
                                                                             ) ["stringValue"] as! String)
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#restaurantAddress2",
                                                                     with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                             ) ["fields"] as? [String: Any] ?? [:]
                                                                             ) ["address2"] as? [String: Any] ?? [:]
                                                                             ) ["stringValue"] as! String)
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#restaurantAddress3",
                                                                     with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                             ) ["fields"] as? [String: Any] ?? [:]
                                                                             ) ["address3"] as? [String: Any] ?? [:]
                                                                             ) ["stringValue"] as! String)
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#restaurantVat",
                                                                     with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                             ) ["fields"] as? [String: Any] ?? [:]
                                                                             ) ["vatNumber"] as? [String: Any] ?? [:]
                                                                             ) ["stringValue"] as! String)
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#restaurantPhoneNumber",
                                                                     with: ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                             ) ["fields"] as? [String: Any] ?? [:]
                                                                             ) ["phoneNumber"] as? [String: Any] ?? [:]
                                                                             ) ["stringValue"] as! String)
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#name", with: DataHolder.name ?? "")

            if DataHolder.deliveryMode == "delivery" {
                let customerAddress = """
                        <tr>
                            <td style="text-align:left;">\(DataHolder.street!)</td>
                        </tr>
                        <tr>
                            <td style="text-align:left;">\(DataHolder.zip!) \(DataHolder.city!)</td>
                        </tr>
                    """
                confirmationHtml = confirmationHtml.replacingOccurrences(of: "#customerAddress", with: customerAddress)
            } else {
                confirmationHtml = confirmationHtml.replacingOccurrences(of: "#customerAddress", with: "")
            }

            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#phone", with: DataHolder.phoneNumber ?? "")
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#email", with: DataHolder.email ?? "")

            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#orderNumberKey",
                                                                     with: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["cart"] as? [String: Any] ?? [:]
                                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) [DataHolder.internationalizeLabel(labelName: "orderNumber", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                                                 ) ["stringValue"] as? String ?? "")
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#orderNumber", with: randomOrderNumber)

            let formatter = DateFormatter()
            formatter.dateFormat = ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["cart"] as? [String: Any] ?? [:]
                                            ) ["mapValue"] as? [String: Any]) ?? [:]
                                            ) ["fields"] as? [String: Any] ?? [:]
                                            ) ["dateFormatPattern"] as? [String: Any] ?? [:]
                                            ) ["stringValue"] as? String ?? ""

            let orderTime = formatter.string(from: Date())
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#orderTimeKey",
                                                                     with: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["cart"] as? [String: Any] ?? [:]
                                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) [DataHolder.internationalizeLabel(labelName: "orderTime", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                                                 ) ["stringValue"] as? String ?? "")
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#orderTime",
                                                                     with: orderTime)

            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#deliveryModeKey",
                                                                     with: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) ["cart"] as? [String: Any] ?? [:]
                                                                                 ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                 ) ["fields"] as? [String: Any] ?? [:]
                                                                                 ) [DataHolder.internationalizeLabel(labelName: "deliveryMode", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                                                                 ) ["stringValue"] as? String ?? "")
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#deliveryMode", with: deliveryModeSelected)

            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#foodOverview", with: foodOverview)
            confirmationHtml = confirmationHtml.replacingOccurrences(of: "#summarySection", with: summarySection)

            var confirmationSubject = (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                             ) ["fields"] as? [String: Any] ?? [:]
                                             ) ["cart"] as? [String: Any] ?? [:]
                                             ) ["mapValue"] as? [String: Any]) ?? [:]
                                             ) ["fields"] as? [String: Any] ?? [:]
                                             ) [DataHolder.internationalizeLabel(labelName: "confirmationSubject", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                                             ) ["stringValue"] as? String ?? "").replacingOccurrences(of: "%s", with: "%@")
            if (!Constants.Config.isProd) {
                confirmationSubject = "[TEST] " + confirmationSubject
            }
            let confirmationSubjectForUser = String(format: confirmationSubject,
                                                    ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                        ) ["fields"] as? [String: Any] ?? [:]
                                                        ) ["address1"] as? [String: Any] ?? [:]
                                                        ) ["stringValue"] as! String)
            let confirmationSubjectForRestaurant = String(format: confirmationSubject, DataHolder.name ?? "")

            if (!isSent) {
                isSent = true // to prevent double email through button mashing. gui recompose of the button is too slow to catch this.

                let isSentSuccess: Bool

                if (DataHolder.useWhatsApp == true) {
                    isSentSuccess = sendWhatsAppMessage(url: ((((((((DataHolder.whatsAppConfig["mapValue"]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["endpoint"] as? [String: Any] ?? [:]
                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["url"] as? [String: Any] ?? [:]
                                               ) ["stringValue"] as! String,
                                             method: ((((((((DataHolder.whatsAppConfig["mapValue"]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["endpoint"] as? [String: Any] ?? [:]
                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["method"] as? [String: Any] ?? [:]
                                                  ) ["stringValue"] as! String,
                                             apiKey: ((((DataHolder.whatsAppConfig["mapValue"]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["apiKey"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String,
                                    collection: Constants.Firebase.collection,
                                    document: Constants.Firebase.document,
                                    userSubject: confirmationSubjectForUser,
                                    restaurantSubject: confirmationSubjectForRestaurant,
                                    message: convertFromHtmlToWhatsAppFormat(confirmationHtml: confirmationHtml),
                                    useInternationalNames: useInternationalNames

                    )
                } else {
                    isSentSuccess = sendEmail(url: ((((((((DataHolder.emailConfig["mapValue"]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["endpoint"] as? [String: Any] ?? [:]
                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                               ) ["fields"] as? [String: Any] ?? [:]
                                               ) ["url"] as? [String: Any] ?? [:]
                                               ) ["stringValue"] as! String,
                                             method: ((((((((DataHolder.emailConfig["mapValue"]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["endpoint"] as? [String: Any] ?? [:]
                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["method"] as? [String: Any] ?? [:]
                                                  ) ["stringValue"] as! String,
                                             apiKey: ((((DataHolder.emailConfig["mapValue"]) ?? [:]
                                              ) ["fields"] as? [String: Any] ?? [:]
                                              ) ["apiKey"] as? [String: Any] ?? [:]
                                              ) ["stringValue"] as! String,
                                    collection: Constants.Firebase.collection,
                                    document: Constants.Firebase.document,
                                    email: DataHolder.email!,
                                    message: confirmationHtml,
                                    userSubject: confirmationSubjectForUser,
                                    restaurantSubject: confirmationSubjectForRestaurant
                    )
                }

                let isSuccess: Bool

                if (Constants.Config.isProd) {

                    let updatePriceSuccess = updateCumulatedOrdersPrice(url: ((((((((DataHolder.commission["mapValue"]) ?? [:]
                                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                                               ) ["endpoint"] as? [String: Any] ?? [:]
                                                                               ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                               ) ["fields"] as? [String: Any] ?? [:]
                                                                               ) ["url"] as? [String: Any] ?? [:]
                                                                               ) ["stringValue"] as! String,
                                                                    method: ((((((((DataHolder.commission["mapValue"]) ?? [:]
                                                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                                                  ) ["endpoint"] as? [String: Any] ?? [:]
                                                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                                                  ) ["method"] as? [String: Any] ?? [:]
                                                                                  ) ["stringValue"] as! String,
                                                                    apiKey: ((((DataHolder.commission["mapValue"]) ?? [:]
                                                                              ) ["fields"] as? [String: Any] ?? [:]
                                                                              ) ["apiKey"] as? [String: Any] ?? [:]
                                                                              ) ["stringValue"] as! String,
                                                                    collection: Constants.Firebase.collection,
                                                                    document: Constants.Firebase.document,
                                                                    price: DataHolder.totalPrice
                    )

                    isSuccess = updatePriceSuccess && isSentSuccess

                } else {

                    isSuccess = isSentSuccess

                }

                if (isSuccess) {

                    isOrderButtonEnabled = false
                    showingSuccessAlert = true
                    WKInterfaceDevice.current().play(.success)

                    // reset so that the user cannot re-enter CartActivity until the app closes
                    DataHolder.cart = OrderedDictionary<Int, Int>()
                    DataHolder.foodToOptionsMapping = OrderedDictionary<Int, OrderedCollections.OrderedSet<OrderedCollections.OrderedSet<Int>>>()
                    DataHolder.totalPrice = 0.0

                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                                                  ) ["cart"] as? [String: Any] ?? [:]
                                                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                                                  ) ["confirmationDurationMs"] as? [String: Any] ?? [:]
                                                                                  ) ["integerValue"] as? Int ?? 5500) / 1000.0) {
                        exit(EXIT_SUCCESS)
                    }
                } else {
                    showingFailureAlert = true
                    WKInterfaceDevice.current().play(.failure)

                    // give the user another chance to purchase his products, if order has failed
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                                                   ) ["cart"] as? [String: Any] ?? [:]
                                                                                   ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                                   ) ["fields"] as? [String: Any] ?? [:]
                                                                                   ) ["failureDurationMs"] as? [String: Any] ?? [:]
                                                                                   ) ["integerValue"] as? Int ?? 5500) / 1000.0) {
                        isSent = false
                        isOrderButtonEnabled = true
                    }
                }
            }
        } else {
            showingClosedAlert = true
            WKInterfaceDevice.current().play(.failure)

            // the restaurant has closed in the meantime, i.e. while the app was open, according to the opening times the app fetched at the initial startup
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["cart"] as? [String: Any] ?? [:]
                                                                           ) ["mapValue"] as? [String: Any]) ?? [:]
                                                                           ) ["fields"] as? [String: Any] ?? [:]
                                                                           ) ["failureDurationMs"] as? [String: Any] ?? [:]
                                                                           ) ["integerValue"] as? Int ?? 5500) / 1000.0) {
                isOrderButtonEnabled = true
            }
        }

    }
    
    func processForView(amounts: inout [Int],
                        foodNames: inout [String],
                        pricesFormatted: inout [String],
                        isMainFoods: inout [Bool],
                        foodOverview: inout String,
                        totalPrice: inout Double,
                        useInternationalNames: Bool) {

        for id in DataHolder.cart.keys {
            let amountOptional = DataHolder.cart[id]
            
            if (amountOptional != nil && amountOptional! > 0) {
                let amount = amountOptional!
                
                let itemPrice = DataHolder.food.first(where: { $0.id == id })?.price ??
                DataHolder.options[id]?.price ?? 0.0

                let product = Double(amount) * itemPrice

                totalPrice += product
                let priceFormatted = DataHolder.formatPrice(price: product, includeCurrency: false)

                let isMainFood = DataHolder.food.first(where: { $0.id == id }) != nil

                var foodName = isMainFood
                ? (useInternationalNames
                   ? DataHolder.food.first(where: { $0.id == id })?.nameEn ?? ""
                   : DataHolder.food.first(where: { $0.id == id })?.name ?? "")
                : (useInternationalNames
                   ? DataHolder.options[id]?.nameEn ?? ""
                   : DataHolder.options[id]?.name ?? "")

                foodOverview += """
                                <tr>
                                    <td style="text-align:center;vertical-align:top;\(isMainFood ? "font-weight:bold;" : "");font-size:15px;width:45px;">
                                        \(amount)
                                    </td>
                                    <td></td>
                                    <td style="\(isMainFood ? "text-align:left;vertical-align:top;" : "")">
                                        <span style="\(isMainFood ? "font-size:15px;font-weight:bold;" : "font-size:14px;")">
                                            \(foodName)
                                        </span>
                                    </td>
                                    <td></td>
                                    <td></td>
                                    <td style="text-align:right;padding-right:15px;vertical-align:top;\(isMainFood ? "font-weight:bold;" : "");width:60px;font-size:15px;">
                                        \(priceFormatted)
                                    </td>
                                </tr>
                            """

                amounts.append(amount)
                pricesFormatted.append(priceFormatted)
                isMainFoods.append(isMainFood)
                foodNames.append(foodName)
            }
        }
    }
    
    @ViewBuilder
    func buildView(amounts: [Int],
                   foodNames: [String],
                   pricesFormatted: [String],
                   isMainFoods: [Bool],
                   edgeColumnLeft: Double,
                   centerColumn: Double,
                   edgeColumnRight: Double) -> some View {
            ForEach(0..<amounts.count, id: \.self) { i in
                HStack {
                    Text("\(amounts[i])")
                        .font(.system(size: isMainFoods[i] ? 14 : 11))
                        .padding(.top, isMainFoods[i] ? 10 : 8)
                        .frame(width: edgeColumnLeft, alignment: .leading)
                    
                    Text(foodNames[i])
                        .font(.system(size: isMainFoods[i] ? 14 : 11))
                        .padding(.top, isMainFoods[i] ? 10 : 8)
                        .frame(width: centerColumn, alignment: .leading)
                    
                    Text(pricesFormatted[i])
                        .font(.system(size: isMainFoods[i] ? 14 : 11))
                        .padding(.top, isMainFoods[i] ? 10 : 8)
                        .frame(width: edgeColumnRight, alignment: .leading)
                }
        }
    }
    
    func convertFromHtmlToWhatsAppFormat(confirmationHtml: String) -> [String] {
        var stringBuilder = ""
        // Graph API: "Param text cannot have new-line/tab characters or more than 4 consecutive spaces". Sudden change in 01.2025. Therefore, use [String] instead of a single String so that can use multiple parameters for line breaks.
        var result: [String] = []

        do {
            let document: Document = try SwiftSoup.parse(confirmationHtml)

            // Select all tables
            let tables = try document.select("table[style='width:100%;font-family:Calibri, serif;']")

            // 1. Restaurant Information Table
            if !tables.isEmpty {
                let restaurantTable = tables[0]
                for row in try restaurantTable.select("tr") {
                    if let cell = try row.select("td").first() {
                        let text = try cell.text().trimmingCharacters(in: .whitespacesAndNewlines)
                        let style = try cell.attr("style")
                        if !text.isEmpty {
                            if style.lowercased().contains("font-weight:bold") {
                                stringBuilder += "*\(text)*    "
                            } else {
                                stringBuilder += "\(text)    "
                            }
                        }
                    }
                }
                while stringBuilder.contains("        ") {
                    stringBuilder = stringBuilder.replacingOccurrences(of: "        ", with: "    ")
                }
                result.append(stringBuilder.trimmingCharacters(in: .whitespacesAndNewlines))
            }

            // 2. Customer Information Table
            if tables.count > 1 {
                stringBuilder = ""
                let customerTable = tables[1]
                for row in try customerTable.select("tr") {
                    if let cell = try row.select("td").first() {
                        let text = try cell.text().trimmingCharacters(in: .whitespacesAndNewlines)
                        let style = try cell.attr("style")
                        if !text.isEmpty {
                            if style.lowercased().contains("font-weight:bold") {
                                stringBuilder += "*\(text)*    "
                            } else {
                                stringBuilder += "\(text)    "
                            }
                        }
                    }
                }
                while stringBuilder.contains("        ") {
                    stringBuilder = stringBuilder.replacingOccurrences(of: "        ", with: "    ")
                }
                result.append(stringBuilder.trimmingCharacters(in: .whitespacesAndNewlines))
            }

            // 3. Order Details Table
            if tables.count > 2 {
                var orderBuilder = ""
                var deliveryModeBuilder = ""

                let lastTable = tables[2]
                let rows = try lastTable.select("tr")

                let orderDetailsTable = try rows[1].select("table")[0]
                let foodTable = try rows[6].select("table")[0]
                let totalTable = rows[rows.count - 3]

                let orderDetailsEntries = try orderDetailsTable.select("tr")
                for (index, entry) in orderDetailsEntries.enumerated() {
                    let cells = try entry.select("td")
                    let isLastEntry = index == orderDetailsEntries.count - 1

                    for (detailsIndex, cell) in cells.enumerated() {
                        if detailsIndex == 0 {
                            if isLastEntry {
                                deliveryModeBuilder += "*\(try cell.text())* "
                            } else {
                                orderBuilder += "*\(try cell.text())* "
                            }
                        } else if detailsIndex == 1 {
                            if isLastEntry {
                                deliveryModeBuilder += "\(try cell.text())    "
                            } else {
                                orderBuilder += "\(try cell.text())    "
                            }
                        }
                    }
                }

                while orderBuilder.contains("        ") {
                    orderBuilder = orderBuilder.replacingOccurrences(of: "        ", with: "    ")
                }
                result.append(orderBuilder.trimmingCharacters(in: .whitespacesAndNewlines))

                while deliveryModeBuilder.contains("        ") {
                    deliveryModeBuilder = deliveryModeBuilder.replacingOccurrences(of: "        ", with: "    ")
                }
                result.append(deliveryModeBuilder.trimmingCharacters(in: .whitespacesAndNewlines))

                stringBuilder = ""
                let foodTableEntries = try foodTable.select("tr")
                for entry in foodTableEntries.dropLast() { // Exclude the last row
                    let cells = try entry.select("td")
                    for (foodIndex, cell) in cells.enumerated() {
                        if foodIndex == 0 {
                            if try cell.attr("style").lowercased().contains("font-weight:bold") {
                                stringBuilder += "*\(try cell.text())x "
                            } else {
                                stringBuilder += "\(try cell.text())x "
                            }
                        } else if foodIndex == 2 {
                            stringBuilder += "\(try cell.text().trimmingCharacters(in: .whitespacesAndNewlines)): "
                        } else if foodIndex == 5 {
                            if try cell.attr("style").lowercased().contains("font-weight:bold") {
                                stringBuilder += "\(try cell.text())*    "
                            } else {
                                stringBuilder += "\(try cell.text())    "
                            }
                        }
                    }
                }
                while stringBuilder.contains("        ") {
                    stringBuilder = stringBuilder.replacingOccurrences(of: "        ", with: "    ")
                }
                result.append(stringBuilder.trimmingCharacters(in: .whitespacesAndNewlines))

                stringBuilder = ""
                if DataHolder.deliveryMode == "delivery" {
                    let deliveryFeeTable = rows[rows.count - 4]
                    let deliveryFeeTableEntries = try deliveryFeeTable.select("td")
                    for (index, entry) in deliveryFeeTableEntries.enumerated() {
                        if (index == 0) {
                            stringBuilder += "\(try entry.text()) "
                        } else {
                            stringBuilder += "\(try entry.text())"
                        }
                    }
                    while stringBuilder.contains("        ") {
                        stringBuilder = stringBuilder.replacingOccurrences(of: "        ", with: "    ")
                    }
                    stringBuilder += "    "
                }
                let totalTableEntries = try totalTable.select("td")
                for (index, entry) in totalTableEntries.enumerated() {
                    if index == 0 {
                        stringBuilder += "*\(try entry.text()) "
                    } else if index == 1 {
                        stringBuilder += "\(try entry.text())"
                    } else {
                        stringBuilder += "\(try entry.text())*"
                    }
                }
                while stringBuilder.contains("        ") {
                    stringBuilder = stringBuilder.replacingOccurrences(of: "        ", with: "    ")
                }
                result.append(stringBuilder.trimmingCharacters(in: .whitespacesAndNewlines))
            }

        } catch Exception.Error(let type, let message) {
            print("\(type): \(message)")
        } catch {
            print("Error parsing HTML.")
        }

        return result
    }

    struct UpdateOrderRequestBody: Encodable {
        let collection: String
        let document: String
        let price: Double
    }

    func updateCumulatedOrdersPrice(url: String, method: String, apiKey: String, collection: String, document: String, price: Double) -> Bool {

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.httpBody = try? JSONEncoder().encode(UpdateOrderRequestBody(collection: collection, document: document, price: price))

        request.addValue(apiKey, forHTTPHeaderField: "apiKey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var success = true

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                success = false
            }
        }

        dataTask.resume()

        return success
    }

    func sendWhatsAppMessage(url: String, method: String, apiKey: String, collection: String, document: String, userSubject: String, restaurantSubject: String, message: [String], useInternationalNames: Bool) -> Bool {
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method

        let body = [
            "collection": collection,
            "document": document,
            "phoneNumber": DataHolder.phoneNumber,
            "userTitle": userSubject,
            "restaurantTitle": restaurantSubject,
            "messageFirst": message[0],
            "messageSecond": message[1],
            "messageThird": message[2],
            "messageFourth": message[3],
            "messageFifth": message[4],
            "messageSixth": message[5],
            "language": useInternationalNames ? "en" : Constants.Firebase.localLanguage,
            "templateName": ((((DataHolder.whatsAppConfig["mapValue"]) ?? [:]
                              ) ["fields"] as? [String: Any] ?? [:]
                              ) ["templateName"] as? [String: Any] ?? [:]
                              ) ["stringValue"] as? String
        ]
        request.httpBody = try? JSONEncoder().encode(body)

        request.addValue(apiKey, forHTTPHeaderField: "apiKey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var success = true

        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                success = false
            }
        }

        dataTask.resume()

        return success
    }

    func sendEmail(url: String, method: String, apiKey: String, collection: String, document: String, email: String, message: String, userSubject: String, restaurantSubject: String) -> Bool {

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method

        let body = [
            "collection": collection,
            "document": document,
            "email": email,
            "message": message,
            "userSubject": userSubject,
            "restaurantSubject": restaurantSubject,
        ]
        request.httpBody = try? JSONEncoder().encode(body)

        request.addValue(apiKey, forHTTPHeaderField: "apiKey")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        var success = true
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                
            }
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode != 200 {
                success = false
            }
        }

        dataTask.resume()

        return success
    }
}
