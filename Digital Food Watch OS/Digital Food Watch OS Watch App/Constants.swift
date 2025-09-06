import Foundation

struct Constants {
    struct Firebase {
        static let collection = "redacted"
        static let document = "redacted"
        static let globalCollection = "redacted"
        static let globalDocument = "redacted"
        static let country = "redacted"
        static let localLanguage = "redacted"
    }
    struct UI {
        static let chipCornerRadius = 25
        static let rectangleCornerRadius = 10
        static let goUpButtonBottomPadding = -31
        static let splashScreenWidth = 100
        static let splashScreenHeight = 100
        static let foodButtonWidth = 60
        static let foodButtonHeight = 60
    }
    struct Config {
        #if PROD
        static let isProd = true
        #else
        static let isProd = false
        #endif
    }
}
