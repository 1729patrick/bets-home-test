import BetsCore

/// This class simulates bet items coming from a remote server.
/// Do not modify.
class RemoteBetService: BetService {
    private static let delay: UInt64 = 1_000_000_000
    
    public static let instance = RemoteBetService()
    
    private init() { }
    
    private var bets: [Bet] = [
        Bet(name: "Winning team", sellIn: 8, quality: 15),
        Bet(name: "Total score", sellIn: 5, quality: 26),
        Bet(name: "Player performance", sellIn: 9, quality: 4),
        Bet(name: "First goal scorer", sellIn: 10, quality: 49),
        Bet(name: "Number of fouls", sellIn: 4, quality: 21),
        Bet(name: "Corner kicks", sellIn: 9, quality: 32),
        Bet(name: "Yellow cards", sellIn: 0, quality: 45),
        Bet(name: "Red cards", sellIn: 2, quality: 11),
        Bet(name: "Offsides", sellIn: 2, quality: 14),
        Bet(name: "Penalties", sellIn: 4, quality: 10),
        Bet(name: "Half-time score", sellIn: 1, quality: 42),
        Bet(name: "Clean sheet", sellIn: 10, quality: 34),
        Bet(name: "Hat trick", sellIn: 9, quality: 32),
        Bet(name: "Number of sets won", sellIn: 8, quality: 17),
        Bet(name: "Number of aces", sellIn: 6, quality: 46),
        Bet(name: "Set score", sellIn: 9, quality: 12),
    ]
    
    func loadBets() async throws -> [Bet] {
        try await Task.sleep(nanoseconds: RemoteBetService.delay)
        return bets
    }
    
    func saveBets(_ bets: [Bet]) async throws {
        try await Task.sleep(nanoseconds: RemoteBetService.delay)
        self.bets = bets
    }
}
