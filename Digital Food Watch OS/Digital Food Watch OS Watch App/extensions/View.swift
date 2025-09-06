import SwiftUI

// Custom View Modifier for Conditional Padding
extension View {
    @ViewBuilder func ifMorePaddingNeeded<Content: View>(transform: (Self) -> Content) -> some View {
        if #available(watchOS 11.0, *) {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func attemptBold() -> some View {
        if #available(watchOS 9.0, *) {
            self.bold()
        } else {
            self
        }
    }
}
