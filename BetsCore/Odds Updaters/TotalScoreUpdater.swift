struct TotalScoreUpdater: BetUpdater {
    func updateQualityBySellIn(for bet: Bet) -> Int {
        guard bet.sellIn < 0 else {
            return bet.quality
        }

        return 0
    }

    func updateQuality(for bet: Bet) -> Int {
        var quality = bet.quality

        if quality < 50 {
            quality += 1
        }

        if bet.sellIn < 11 && quality < 50 {
            quality += 1
        }

        if bet.sellIn < 6 && quality < 50 {
            quality += 1
        }

        return quality
    }

    func updateSellIn(for bet: Bet) -> Int {
        bet.sellIn - 1
    }
}
