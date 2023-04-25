struct PlayerPerformanceUpdater: BetUpdater {
    func updateQualityBySellIn(for bet: Bet) -> Int {
        guard bet.sellIn < 0 else {
            return bet.quality
        }

        if bet.quality < 50 {
            return bet.quality + 1
        }

        return bet.quality
    }

    func updateQuality(for bet: Bet) -> Int {
        if bet.quality < 50 {
            return bet.quality + 1
        }

        return bet.quality
    }

    func updateSellIn(for bet: Bet) -> Int {
        bet.sellIn - 1
    }
}
