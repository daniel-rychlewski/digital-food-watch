import SwiftUI

struct InactiveScreen: View {
    var body: some View {
        VStack {
            Text(String(localized: "inactiveScreenHeading"))
                .font(.system(size: 14))
            Text(String(localized: "inactiveScreenDescription"))
                .font(.system(size: 11))
                .padding(.top, 8)
        }
    }
}
