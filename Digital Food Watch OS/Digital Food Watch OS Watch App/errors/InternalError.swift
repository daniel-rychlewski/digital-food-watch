import SwiftUI

struct InternalError: View {
    var body: some View {
        VStack {
            Text(String(localized: "internalErrorHeading"))
                .font(.system(size: 14))
            Text(String(localized: "internalErrorDescription"))
                .font(.system(size: 11))
                .padding(.top, 8)
        }
    }
}
