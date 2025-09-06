import SwiftUI
import QRCode

struct CryptoActivity : View {

    @State private var isPolygonTicked: Bool = true
    @State private var isSolanaTicked: Bool = false
    
    @State private var isUsdcTicked: Bool = true
    @State private var isUsdtTicked: Bool = false
    
    @State private var isNativeTicked: Bool = true
    @State private var isMetamaskTicked: Bool = false
    @State private var isTrustTicked: Bool = false
    
    @State var isOrderButtonEnabled: Bool = true
    @State private var showingSuccessAlert = false
    @State private var showingFailureAlert = false
    @State private var showingClosedAlert = false
    
    @State private var qrLink: String? = nil
    
    @State private var qrImage: UIImage?
    
    @State private var nativeAmount: String = ""
    @State private var metaMaskAmount: String = ""
    @State private var trustAmount: String = ""
    
    @State private var minimumAcceptablePaymentThreshold: Double = 0.0
    
    @State private var payments: [PolygonTransfer] = []
    
    @Environment(\.presentationMode) private var presentationMode
    
    var useInternationalNames: Bool
    var orderNumber: String
    var totalPriceWithTransactionFees: Double
    
    let currencies: [String: [String: String]] = [
        "solana": [
            "usdc": "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            "usdt": "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"
        ],
        "polygon": [
            "usdc": "0x3c499c542cef5e3811e1192ce70d8cc03d5c3359",
            "usdt": "0xc2132d05d31c914a87c6611c10748aeb04b58e8f"
        ]
    ]
    
    var onPaymentResult: () -> Void
    
    var body: some View {

        let cryptoPadding: CGFloat = 8
        
        GeometryReader { geometry in
            let qrSize = geometry.size.width * 2 / 3

            ScrollView {
                VStack {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["crypto"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "headlineText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
                    )
                    .font(.system(size: 18))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                }

                VStack {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["crypto"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "networkText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
                    )
                    Toggle(isOn: $isPolygonTicked) {
                        Text("Polygon")
                    }
                    .padding(.trailing, cryptoPadding)
                    .onChange(of: isPolygonTicked) { newValue in
                        isSolanaTicked = !newValue

                        refreshCode()
                    }
                    .padding(.top, 6)

                    Toggle(isOn: $isSolanaTicked) {
                        Text("Solana")
                    }
                    .padding(.trailing, cryptoPadding)
                    .onChange(of: isSolanaTicked) { newValue in
                        isPolygonTicked = !newValue
                        
                        if (isMetamaskTicked) {
                            isMetamaskTicked = false // Metamask does not support it
                            isNativeTicked = true
                        }

                        refreshCode()
                    }
                    .padding(.top, 6)

                }

                VStack {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["crypto"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "currencyText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
                    )
                    Toggle(isOn: $isUsdcTicked) {
                        Text("USDC")
                    }
                    .padding(.trailing, cryptoPadding)
                    .onChange(of: isUsdcTicked) { newValue in
                        isUsdtTicked = !newValue

                        refreshCode()
                    }
                    .padding(.top, 6)

                    Toggle(isOn: $isUsdtTicked) {
                        Text("USDT")
                    }
                    .padding(.trailing, cryptoPadding)
                    .onChange(of: isUsdtTicked) { newValue in
                        isUsdcTicked = !newValue

                        refreshCode()
                    }
                    .padding(.top, 6)
                }

                VStack {
                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["crypto"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "protocolText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
                    )
                    Toggle(isOn: $isNativeTicked) {
                        Text("Native")
                    }
                    .disabled(isNativeTicked)
                    .padding(.trailing, cryptoPadding)
                    .onChange(of: isNativeTicked) { newValue in
                        if (newValue) {
                            isMetamaskTicked = false
                            isTrustTicked = false
                        }

                        refreshCode()
                    }
                    .padding(.top, 6)

                    Toggle(isOn: $isMetamaskTicked) {
                        Text("Metamask")
                    }
                    .disabled(isSolanaTicked)
                    .padding(.trailing, cryptoPadding)
                    .onChange(of: isMetamaskTicked) { newValue in
                        if (newValue) {
                            isNativeTicked = false
                            isTrustTicked = false
                        } else {
                            // do that at least 1 is ticked. why relevant: because might be unchecked due to choice of unsupported network i.e. Solana
                            if (!isTrustTicked && !isNativeTicked) {
                                isNativeTicked = true
                            }
                        }

                        refreshCode()
                    }
                    .padding(.top, 6)

                    Toggle(isOn: $isTrustTicked) {
                        Text("Trust")
                    }
                    .padding(.trailing, cryptoPadding)
                    .onChange(of: isTrustTicked) { newValue in
                        if (newValue) {
                            isNativeTicked = false
                            isMetamaskTicked = false
                        } else {
                            if (!isMetamaskTicked && !isNativeTicked) {
                                isNativeTicked = true
                            }
                        }

                        refreshCode()
                    }
                    .padding(.top, 6)

                    Text(
                        ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["crypto"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "qrScanInstructionsText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String
                    )
                    
                    Text(
                        String(
                            format: (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) ["crypto"] as? [String: Any] ?? [:]
                        ) ["mapValue"] as? [String: Any]) ?? [:]
                        ) ["fields"] as? [String: Any] ?? [:]
                        ) [DataHolder.internationalizeLabel(labelName: "contractAddressInstructions", useInternationalNames: useInternationalNames) + "Text"] as? [String: Any] ?? [:]
                        ) ["stringValue"] as! String).replacingOccurrences(of: "%s", with: "%@"),
                            currencies[isPolygonTicked ? "polygon" : (isSolanaTicked ? "solana" : "polygon")]?[isUsdcTicked ? "usdc" : "usdt"] ?? "ERROR"
                        )
                    )
                }

                VStack {
                    if let qrLink = qrLink, let qrImage = generateQRCode(content: qrLink) {
                        Image(uiImage: qrImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: qrSize, height: qrSize)
                            .padding(.top, 6)
                    } else {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                            .frame(width: qrSize, height: qrSize)
                            .padding(.top, 6)
                    }
                }
                .onAppear {
                    if qrLink == nil {
                        self.fetchExchangeRate(
                            amount: totalPriceWithTransactionFees
                        ) { result in
                            if let result = result {
                                self.nativeAmount = String(result)
                                    .replacingOccurrences(of: ",", with: "")
                                self.metaMaskAmount = String(result /* for crypto, give amount in terms of smallest unit */ * 1_000_000)
                                    .replacingOccurrences(of: ",", with: "")
                                self.trustAmount = String(result)
                                self.minimumAcceptablePaymentThreshold = result - 0.0001 // that is the cut-off of precision for Metamask wallet upon scanning the QR code, so choose that amount less as the minimum to check for. Trust precision would be 0.000001 i.e. overruled by Metamask
                                refreshCode()
                            } else {
                                print("Failed to fetch exchange rate")
                            }
                        }
                    }
                }

                VStack {
                    Button(action: {
                        Task {
                            payments = await checkPolygonPayments(
                                receiver: isPolygonTicked ?
                                        (((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["crypto"] as? [String: Any] ?? [:]
                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["polygonAddress"] as? [String: Any] ?? [:]
                                                  ) ["stringValue"] as? String ?? "")
                                : (isSolanaTicked ?
                                        (((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["crypto"] as? [String: Any] ?? [:]
                                                  ) ["mapValue"] as? [String: Any]) ?? [:]
                                                  ) ["fields"] as? [String: Any] ?? [:]
                                                  ) ["solanaAddress"] as? [String: Any] ?? [:]
                                                  ) ["stringValue"] as? String ?? "")
                                   : ""),
                                apiKey: DataHolder.cryptoApiKey!,
                                minAmount: minimumAcceptablePaymentThreshold
                            )

                            if (!payments.isEmpty || isSolanaTicked) {
                                onPaymentResult()
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                // Stay on the screen and show error!
                                isOrderButtonEnabled = false

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
                                    isOrderButtonEnabled = true
                                }
                            }
                        }

                    }) {
                        Text(
                            ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) ["crypto"] as? [String: Any] ?? [:]
                            ) ["mapValue"] as? [String: Any]) ?? [:]
                            ) ["fields"] as? [String: Any] ?? [:]
                            ) [DataHolder.internationalizeLabel(labelName: "paymentFinishedText", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                            ) ["stringValue"] as! String
                        )
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
                                          cartPadding: cryptoPadding,
                                          showingSuccessAlert: $showingSuccessAlert,
                                          showingFailureAlert: $showingFailureAlert,
                                          showingClosedAlert: $showingClosedAlert
                    )

                }

            }
        }
    }
    
    private func generateQRCode(content: String) -> UIImage? {
        do {
            let doc = try QRCode.Document(utf8String: content)
            
            // Generate at a fixed base dimension (will scale in SwiftUI)
            let baseDimension = 1000 // Large size for high quality
            let cgImage = try doc.cgImage(dimension: baseDimension)
            return UIImage(cgImage: cgImage)
            
        } catch {
            print("Error generating QR code: \(error)")
            return nil
        }
    }
    
    private func refreshCode() {
        // Construct the QR code anew with the currently given data.
        var url: String = ""
        
        // Protocol
        if (isNativeTicked && isPolygonTicked) {
            url += "ethereum:"
            
            // Currency
            if (isUsdcTicked) {
                url += currencies["polygon"]?["usdc"] ?? ""
            } else if (isUsdtTicked) {
                url += currencies["polygon"]?["usdt"] ?? ""
            }
            
            // Network
            url += "@137/transfer?address="
            
            url += (((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["crypto"] as? [String: Any] ?? [:]
                          ) ["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["polygonAddress"] as? [String: Any] ?? [:]
                          ) ["stringValue"] as? String ?? "")
            
            url += "&uint256="
            
            url += nativeAmount
            
        } else if (isNativeTicked && isSolanaTicked) {
            url += "solana:"

            url += (((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                             ) ["fields"] as? [String: Any] ?? [:]
                             ) ["crypto"] as? [String: Any] ?? [:]
                             ) ["mapValue"] as? [String: Any]) ?? [:]
                             ) ["fields"] as? [String: Any] ?? [:]
                             ) ["solanaAddress"] as? [String: Any] ?? [:]
                             ) ["stringValue"] as? String ?? "")
            
            url += "?amount="
            
            url += nativeAmount
            
            url += "&spl-token="
            
            // Currency
            if (isUsdcTicked) {
                url += currencies["solana"]?["usdc"] ?? ""
            } else if (isUsdtTicked) {
                url += currencies["solana"]?["usdt"] ?? ""
            }
            
            url += "&memo="
            
            url += orderNumber
            
        } else if (isMetamaskTicked) {
            
            url += "https://metamask.app.link/send/pay-"
            
            // Currency
            if (isUsdcTicked) {
                url += currencies["polygon"]?["usdc"] ?? ""
            } else if (isUsdtTicked) {
                url += currencies["polygon"]?["usdt"] ?? ""
            }
            
            url += "@137/transfer?address="
            
            url += (((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["crypto"] as? [String: Any] ?? [:]
                          ) ["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["polygonAddress"] as? [String: Any] ?? [:]
                          ) ["stringValue"] as? String ?? "")
            
            url += "&uint256="
            
            url += String(format: "%e", Double(self.metaMaskAmount)!).replacingOccurrences(of: "+", with: "")

        } else if (isTrustTicked) {
            
            url += "https://link.trustwallet.com/send?asset="
            
            // Currency
            if (isUsdcTicked) {
                if (isPolygonTicked) {
                    url += "c966_t" + (currencies["polygon"]?["usdc"] ?? "")
                } else if (isSolanaTicked) {
                    url += "c501_t" + (currencies["solana"]?["usdc"] ?? "")
                }
            } else if (isUsdtTicked) {
                if (isPolygonTicked) {
                    url += "c966_t" + (currencies["polygon"]?["usdt"] ?? "")
                } else if (isSolanaTicked) {
                    url += "c501_t" + (currencies["solana"]?["usdt"] ?? "")
                }
            }

            url += "&address="
            
            if (isPolygonTicked) {
                url += (((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["crypto"] as? [String: Any] ?? [:]
                          ) ["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["polygonAddress"] as? [String: Any] ?? [:]
                          ) ["stringValue"] as? String ?? "")
            } else if (isSolanaTicked) {
                url += (((((((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["crypto"] as? [String: Any] ?? [:]
                          ) ["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["solanaAddress"] as? [String: Any] ?? [:]
                          ) ["stringValue"] as? String ?? "")
            }
            
            url += "&amount="

            url += trustAmount

            url += "&memo="

            url += orderNumber
            
        }
        
        qrLink = url
    }

    struct ExchangeRateResponse: Decodable {
        let conversion_rates: [String: Double]
    }
    
    func fetchExchangeRate(
        amount: Double,
        completion: @escaping (Double?) -> Void
    ) {
        let url = URL(string: "https://v6.exchangerate-api.com/v6/" + DataHolder.currencyExchangeApiKey! + "/latest/USD")!
        
        let currencyOfficial = ((((DataHolder.restaurantConfig["mapValue"] as? [String: Any]) ?? [:]
                         ) ["fields"] as? [String: Any] ?? [:]
                         ) ["currencyOfficial"] as? [String: Any] ?? [:]
                         ) ["stringValue"] as! String
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
                let conversionRate = 1 / (result.conversion_rates[currencyOfficial.uppercased()] ?? 1)
                let finalAmount = amount * conversionRate
                DispatchQueue.main.async {
                    completion(finalAmount)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
    
    struct PolygonTransfer: Codable {
        let hash: String
        let from: String
        let to: String
        let value: Double
        let asset: String
        let timestamp: Date
    }

    func checkPolygonPayments(
        receiver: String,
        apiKey: String,
        minAmount: Double
    ) async -> [PolygonTransfer] {
        
        guard let url = URL(string: "https://polygon-mainnet.g.alchemy.com/v2/\(apiKey)") else {
            return []
        }
        
        // USDC + USDT contract addresses on Polygon
        let usdc = (currencies["polygon"]?["usdc"] ?? "")
        let usdt = (currencies["polygon"]?["usdt"] ?? "")
        
        let body: [String: Any] = [
            "jsonrpc": "2.0",
            "id": 1,
            "method": "alchemy_getAssetTransfers",
            "params": [[
                "fromBlock": "0x0",
                "toAddress": receiver,
                "contractAddresses": [usdc, usdt],
                "category": ["erc20"],
                "withMetadata": true,
                "excludeZeroValue": true,
                "maxCount": "0x14" // fetch last 20 transfers
            ]]
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: body)
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.httpBody = data
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (respData, _) = try await URLSession.shared.data(for: req)
            if let json = try JSONSerialization.jsonObject(with: respData) as? [String: Any],
               let result = json["result"] as? [String: Any],
               let transfers = result["transfers"] as? [[String: Any]] {
                
                return transfers.compactMap { t in
                    guard let hash = t["hash"] as? String,
                          let from = t["from"] as? String,
                          let to = t["to"] as? String,
                          let value = t["value"] as? Double,
                          let asset = t["asset"] as? String,
                          let metadata = t["metadata"] as? [String: Any],
                          let blockTimestamp = metadata["blockTimestamp"] as? String
                    else { return nil }
                    
                    // Parse timestamp from ISO8601 string
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    guard let timestamp = formatter.date(from: blockTimestamp) else { return nil }
                    
                    // Check time window: must be within the last minute
                    let oneMinuteAgo = Date().addingTimeInterval(-60)
                    guard timestamp >= oneMinuteAgo else { return nil }
                    
                    // Check min amount
                    guard value >= minAmount else { return nil }
                    
                    return PolygonTransfer(
                        hash: hash,
                        from: from,
                        to: to,
                        value: value,
                        asset: asset,
                        timestamp: timestamp
                    )
                }
            }
        } catch {
            print("Polygon transfers error:", error)
        }
        
        return []
    }
}
