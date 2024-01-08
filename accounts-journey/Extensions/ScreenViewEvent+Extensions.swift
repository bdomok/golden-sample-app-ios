import Foundation
import BackbaseObservability

extension ScreenViewEvent {
    static let journey = "accounts_transactions"

    static var accounts: ScreenViewEvent {
        ScreenViewEvent(name: "accounts", journey: journey)
    }

    static var accountDetails: ScreenViewEvent {
        ScreenViewEvent(name: "account_details", journey: journey)
    }
}
