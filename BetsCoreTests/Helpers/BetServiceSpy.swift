import BetsCore

class BetServiceSpy: BetService {
    var bets: [Bet] = []
    var completeLoadWith: (() async throws -> [Bet])?
    var completeSaveWith: (() async throws -> Void)?

    enum Event {
        case load
        case save
    }

    var events = [Event]()

    func loadBets() async throws -> [Bet] {
        events.append(.load)

        guard let completeLoadWith = completeLoadWith else {
            return bets
        }

        return try await completeLoadWith()
    }

    func saveBets(_ bets: [Bet]) async throws {
        events.append(.save)

        guard let completeSaveWith = completeSaveWith else {
            return self.bets = bets
        }

        return try await completeSaveWith()
    }
}
