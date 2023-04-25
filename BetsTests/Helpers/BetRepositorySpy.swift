import BetsCore

class BetRepositorySpy: BetRepository {
    var bets = [Bet]()

    enum Event {
        case load
        case update
        case save
    }

    var events = [Event]()

    var completeLoadWith: (() async throws -> [Bet])?
    var completeUpdateWith: (() async throws -> [Bet])?
    var completeSaveWith: (() async throws -> Void)?

    func loadBets() async throws -> [BetsCore.Bet] {
        events.append(.load)

        guard let completeLoadWith = completeLoadWith else {
            return bets
        }

        return try await completeLoadWith()

    }

    func updateBets() async throws -> [BetsCore.Bet] {
        events.append(.update)

        guard let completeUpdateWith = completeUpdateWith else {
            return bets
        }

        return try await completeUpdateWith()
    }

    func saveBets(with bets: [BetsCore.Bet]) async throws {
        events.append(.save)

        guard let completeSaveWith = completeSaveWith else {
            return self.bets = bets
        }

        try await completeSaveWith()
    }
}
