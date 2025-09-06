import SwiftUI

struct UpdateError: View {
    var body: some View {
        VStack {
            Text(String(localized: "updateErrorHeading"))
                .font(.system(size: 14))
            Text(String(localized: "updateErrorDescription"))
                .font(.system(size: 11))
                .padding(.top, 8)
        }
    }
}
