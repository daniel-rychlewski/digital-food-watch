import SwiftUI

struct ModeActivity: View {
    @State var selectedOption = DataHolder.deliveryMode
    var useInternationalNames: Bool

    init(useInternationalNames: Bool) {
        self.useInternationalNames = useInternationalNames
    }
	
    var radioOptions: [(String, String)] {
        guard let guiConfigMap = DataHolder.guiConfig["mapValue"] as? [String: Any],
              let fields = guiConfigMap["fields"] as? [String: Any],
              let mode = fields["mode"] as? [String: Any],
              let mapValue = mode["mapValue"] as? [String: Any],
              let modeFields = mapValue["fields"] as? [String: Any],
              let modeOptions = modeFields["modeOptions"] as? [String: Any],
              let modeOptionsArray = modeOptions["arrayValue"] as? [String: Any],
              let modeOptionEntries = modeOptionsArray["values"] as? [[String: Any]]
        else {
            return []
        }
        
        return modeOptionEntries.compactMap { option in
            guard let myOption = (option["mapValue"] as? [String: Any] ?? [:])["fields"] as? [String: Any],
                  let id = (myOption["id"] as? [String: Any] ?? [:]) ["stringValue"] as? String,
                  let textEn = (myOption["textEn"] as? [String: Any] ?? [:]) ["stringValue"] as? String,
                  let text = (myOption["text"] as? [String: Any] ?? [:]) ["stringValue"] as? String
            else {
                return nil
            }
            
            return (id, useInternationalNames ? textEn : text)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(
                    ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) ["chip"] as? [String: Any] ?? [:]
                          ) ["mapValue"] as? [String: Any]) ?? [:]
                          ) ["fields"] as? [String: Any] ?? [:]
                          ) [DataHolder.internationalizeLabel(labelName: "deliveryModeData", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                          ) ["stringValue"] as! String
                )
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                
                ForEach(radioOptions, id: \.0) { option in
                    RadioButton(selectedOption: $selectedOption, id: option.0, text: option.1)
                        .padding(
                            CGFloat(
                                (((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) ["mode"] as? [String: Any] ?? [:]
                                        ) ["mapValue"] as? [String: Any]) ?? [:]
                                        ) ["fields"] as? [String: Any] ?? [:]
                                        ) ["radioColumnPadding"] as? [String: Any] ?? [:]
                                        ) ["integerValue"] as? Int) ?? 0
                            ))
                }
            }
            .onAppear {
                selectedOption = DataHolder.deliveryMode
            }
        }
    }
}

struct RadioButton: View {
    @Binding var selectedOption: String
    let id: String
    let text: String

    var body: some View {
        Button(action: {
            self.selectedOption = self.id
            DataHolder.deliveryMode = selectedOption
        }) {
            HStack {
                Text(self.text)
                    .foregroundColor(.black)
                
                Spacer()
                
                if self.selectedOption == self.id {
                    Image(systemName: "checkmark.circle")
                } else {
                    Image(systemName: "circle")
                }
            }
        }
        .ifMorePaddingNeeded { view in
            view.padding(.horizontal, 16)
        }
        .background(RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous).fill(self.selectedOption == self.id
        ? Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                           ) ["fields"] as? [String: Any] ?? [:]
                           ) ["mode"] as? [String: Any] ?? [:]
                           ) ["mapValue"] as? [String: Any]) ?? [:]
                           ) ["fields"] as? [String: Any] ?? [:]
                           ) ["modeSelectedColor"] as? [String: Any] ?? [:]
                           ) ["stringValue"] as! String)
        : Color(hex: ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                           ) ["fields"] as? [String: Any] ?? [:]
                           ) ["mode"] as? [String: Any] ?? [:]
                           ) ["mapValue"] as? [String: Any]) ?? [:]
                           ) ["fields"] as? [String: Any] ?? [:]
                           ) ["modeColor"] as? [String: Any] ?? [:]
                           ) ["stringValue"] as! String)))
        .cornerRadius(CGFloat(Constants.UI.rectangleCornerRadius))
        .padding(.bottom, 10)
    }
}
