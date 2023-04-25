struct WinningTeamBetUpdater: BetUpdater {
    func updateQualityBySellIn(for bet: Bet) -> Int {
        bet.quality
    }

    func updateQuality(for bet: Bet) -> Int {
        bet.quality
    }

    func updateSellIn(for bet: Bet) -> Int {
        bet.sellIn
    }
}
