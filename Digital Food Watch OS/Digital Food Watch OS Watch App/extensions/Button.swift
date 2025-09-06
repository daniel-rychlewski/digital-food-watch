import SwiftUI

extension Button {
    func formatOrderNowButton(isOrderButtonEnabled: Bool,
                              useInternationalNames: Bool,
                              cartPadding: CGFloat,
                              showingSuccessAlert: Binding<Bool>,
                              showingFailureAlert: Binding<Bool>,
                              showingClosedAlert: Binding<Bool>
                          ) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: CGFloat(Constants.UI.rectangleCornerRadius), style: .continuous)
                .fill(isOrderButtonEnabled
              ? Color(hex:
                ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                      ) ["fields"] as? [String: Any] ?? [:]
                      ) ["cart"] as? [String: Any] ?? [:]
                      ) ["mapValue"] as? [String: Any]) ?? [:]
                      ) ["fields"] as? [String: Any] ?? [:]
                      ) ["cartOrderNowBackgroundColor"] as? [String: Any] ?? [:]
                      ) ["stringValue"] as! String)
              : Color(hex:
                ((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                      ) ["fields"] as? [String: Any] ?? [:]
                      ) ["cart"] as? [String: Any] ?? [:]
                      ) ["mapValue"] as? [String: Any]) ?? [:]
                      ) ["fields"] as? [String: Any] ?? [:]
                      ) ["cartOrderNowDisabledBackgroundColor"] as? [String: Any] ?? [:]
                      ) ["stringValue"] as! String)
             )
        )

        .alert(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                     ) ["fields"] as? [String: Any] ?? [:]
                     ) ["cart"] as? [String: Any] ?? [:]
                     ) ["mapValue"] as? [String: Any]) ?? [:]
                     ) ["fields"] as? [String: Any] ?? [:]
                     ) [DataHolder.internationalizeLabel(labelName: "successMessage", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                     ) ["stringValue"] as! String, isPresented: showingSuccessAlert) {
        }
        .alert(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                     ) ["fields"] as? [String: Any] ?? [:]
                     ) ["cart"] as? [String: Any] ?? [:]
                     ) ["mapValue"] as? [String: Any]) ?? [:]
                     ) ["fields"] as? [String: Any] ?? [:]
                     ) [DataHolder.internationalizeLabel(labelName: "failureMessage", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                     ) ["stringValue"] as! String, isPresented: showingFailureAlert) {
        }
        .alert(((((((((DataHolder.guiConfig["mapValue"] as? [String: Any]) ?? [:]
                     ) ["fields"] as? [String: Any] ?? [:]
                     ) ["cart"] as? [String: Any] ?? [:]
                     ) ["mapValue"] as? [String: Any]) ?? [:]
                     ) ["fields"] as? [String: Any] ?? [:]
                     ) [DataHolder.internationalizeLabel(labelName: "restaurantClosedMessage", useInternationalNames: useInternationalNames)] as? [String: Any] ?? [:]
                     ) ["stringValue"] as! String, isPresented: showingClosedAlert) {
        }
        .disabled(!isOrderButtonEnabled)
        .padding(.trailing, cartPadding)
    
    }
}
