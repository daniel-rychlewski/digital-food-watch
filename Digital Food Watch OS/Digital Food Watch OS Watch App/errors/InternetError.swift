import SwiftUI

struct InternetError: View {
    var body: some View {
        VStack {
            Text(String(localized: "internetErrorHeading"))
                .font(.system(size: 14))
            Text(String(localized: "internetErrorDescription"))
                .font(.system(size: 11))
                .padding(.top, 8)
        }
    }
}
