import Foundation
import BackbaseObservability

extension UserActionEvent {
    static let journey = "accounts_transactions"

    static var refresh: UserActionEvent {
        UserActionEvent(name: "refresh_accounts", journey: journey)
    }

    static var searchAccounts: UserActionEvent {
        UserActionEvent (name: "search_accounts", journey: journey)
    }
}
