//
//  AccountsListViewModel.swift
//  AccountsJourney
//
//  Created by Backbase R&D B.V. on 12/10/2023.
//

import Foundation
import Resolver
import Combine
import BackbaseDesignSystem
import BackbaseObservability

final class AccountsListViewModel: NSObject {
    
    // MARK: - Properties
    @Published private(set) var allAccounts = [AccountUIModel]()
    @Published private(set) var screenState: AccountListScreenState = .loading
    
    var didSelectProduct: ((String) -> Void)?

    @OptionalInjected
    var tracker: Tracker?

    // MARK: - Private
    
    private lazy var accountsListUseCase: AccountsListUseCase = {
        guard let useCase = Resolver.optional(AccountsListUseCase.self) else {
            fatalError("AccountsListUseCase needed to continue")
        }
        return useCase
    }()

    // MARK: - Methods
    func onEvent(_ event: AccountListScreenEvent) {
        switch event {
        case .getAccounts:
            getAccountSummary(fromEvent: .getAccounts)
        case .refresh:
            refresh()
        case .search(let searchString):
            search(for: searchString)
        case .didAppear:
            viewDidAppear()
        }
    }
    
    private func getAccountSummary(fromEvent event: AccountListScreenEvent) {
        var query = ""
        
        if case let .search(searchString) = event {
            query = searchString
        }
        
        screenState  = .loading
        
        accountsListUseCase.getAccountSummary {[weak self] result in
            guard let self else {
                return
            }
            
            switch result {
            case let .success(accountsSummaryResponse):
                allAccounts = accountsSummaryResponse
                    .toMapUI()
                    .generateList(query: query)
                
                if allAccounts.isEmpty {
                    screenState = .emptyResults(
                        stateViewConfiguration(
                            for: .noAccounts, primaryAction: {
                                self.onEvent(.refresh)
                            })
                    )
                } else {
                    screenState = .loaded
                }
                
            case let .failure(errorResponse):
                screenState = .hasError(
                    stateViewConfiguration(
                        for: .loadingFailure(errorResponse),
                        primaryAction: {
                            self.onEvent(.refresh)
                        }
                    )
                )
            }
        }
    }

    private func viewDidAppear() {
        tracker?.publish(event: ScreenViewEvent.accounts)
    }

    private func refresh() {
        getAccountSummary(fromEvent: .refresh)
        tracker?.publish(event: UserActionEvent.refresh)
    }

    private func search(for text: String) {
        getAccountSummary(fromEvent: .search(text))
        tracker?.publish(event: UserActionEvent.searchAccounts)
    }
}
