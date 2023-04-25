import BetsCore

protocol OddsSortingStrategy {
    func sortOdds(_ odds: [Bet]) -> [Bet]
}

class SellInOddsSortingStrategy: OddsSortingStrategy {
    func sortOdds(_ odds: [Bet]) -> [Bet] {
        odds.sorted(by: { $0.sellIn > $1.sellIn })
    }
}
