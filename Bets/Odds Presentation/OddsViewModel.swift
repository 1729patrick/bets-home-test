import UIKit
import BetsCore

protocol OddsViewModel {
    var odds: [Bet] { get }
    func updateOdds() async throws
}

public class OddsRepositoryViewModel: ObservableObject, OddsViewModel {
    @Published var odds = [Bet]()

    private var sortingStrategy: OddsSortingStrategy
    private var repository: BetRepository

    init(repository: BetRepository, sortingStrategy: OddsSortingStrategy) {
        self.repository = repository
        self.sortingStrategy = sortingStrategy
    }

    func updateOdds() async throws {
        odds = try await repository.updateBets()
        odds = sortingStrategy.sortOdds(odds)
    }
}
