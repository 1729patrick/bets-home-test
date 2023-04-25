
public protocol BetService {
    func loadBets() async throws -> [Bet]
    func saveBets(_ bets: [Bet]) async throws
}

public protocol BetRepository {
    func loadBets() async throws -> [Bet]
    func updateBets() async throws -> [Bet]
    func saveBets(with bets: [Bet]) async throws
}

public class ServiceBetRepository: BetRepository {
    private let service: BetService

    public init(service: BetService) {
        self.service = service
    }

    public func loadBets() async throws -> [Bet] {
        try await service.loadBets()
    }

    public func updateBets() async throws -> [Bet] {
        let bets = try await loadBets()

        let updatedBets = bets.map(updateBet)

        try await saveBets(with: updatedBets)

        return updatedBets
    }

    public func saveBets(with bets: [Bet]) async throws {
        try await service.saveBets(bets)
    }
}

extension ServiceBetRepository {
    private func updateBet(_ bet: Bet) -> Bet {
        var bet = bet

        let updater = updater(for: bet)

        bet.quality = updater.updateQuality(for: bet)
        bet.sellIn = updater.updateSellIn(for: bet)
        bet.quality = updater.updateQualityBySellIn(for: bet)

        return bet
    }

    private func updater(for bet: Bet) -> BetUpdater {
        ServiceBetRepository.betUpdaters[bet.name] ?? StandardBetUpdater()
    }
}

extension ServiceBetRepository {
    static let betUpdaters: [String: BetUpdater] = [
        "Player performance": PlayerPerformanceUpdater(),
        "Total score": TotalScoreUpdater(),
        "Winning team": WinningTeamBetUpdater()
    ]
}

