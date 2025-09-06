import SwiftUI

struct LoginError: View {
    var body: some View {
        VStack {
            Text(String(localized: "loginErrorHeading"))
                .font(.system(size: 14))
            Text(String(localized: "loginErrorDescription"))
                .font(.system(size: 11))
                .padding(.top, 8)
        }
    }
}
