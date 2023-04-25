import XCTest
@testable import BetsCore

class BetsRepositoryTests: XCTestCase {
    func test_loadBets_deliveriesEmptyOnEmptyBets() async throws {
        let (service, sut) = makeSUT()

        let expectedResult: [Bet] = []

        service.completeLoadWith = { expectedResult }

        let loadedBets = try await sut.loadBets()

        XCTAssertEqual(loadedBets, expectedResult)
    }

    func test_loadBets_deliveriesBetsOnNonEmptyBets() async throws {
        let (service, sut) = makeSUT()

        let expectedResult: [Bet] = [makeBet(name: "Swift Bet", sellIn: 17, quality: 29)]

        service.completeLoadWith = { expectedResult }

        let loadedBets = try await sut.loadBets()

        XCTAssertEqual(loadedBets, expectedResult)
    }

    func test_loadBets_throwsErrorOnRetrievalError() async throws {
        let (service, sut) = makeSUT()

        service.completeLoadWith = { throw self.anyError() }

        await XCTAssertThrowsError(try await sut.updateBets())
    }

    func test_saveBets_persistsEmptyOnEmptyBets() async throws {
        let (service, sut) = makeSUT()

        let expectedResult: [Bet] = []

        try await sut.saveBets(with: expectedResult)

        XCTAssertEqual(service.bets, expectedResult)
    }

    func test_saveBets_persistsBetsOnNonEmptyBets() async throws {
        let (service, sut) = makeSUT()

        let expectedResult: [Bet] = [makeBet(name: "Swift Bet", sellIn: 17, quality: 29)]

        try await sut.saveBets(with: expectedResult)

        XCTAssertEqual(service.bets, expectedResult)
    }

    func test_saveBets_throwsErrorOnInsertionError() async throws {
        let (service, sut) = makeSUT()

        service.completeSaveWith = { throw self.anyError() }

        await XCTAssertThrowsError(try await sut.saveBets(with: []))
    }

    func test_updateOdds_callsLoadAndSaveOnBetsService() async throws {
        let (service, sut) = makeSUT()

        try await sut.updateBets()

        XCTAssertEqual(service.events, [.load, .save])
    }

    func test_updateBets_deliveriesEmptyOnEmptyBets() async throws {
        let (service, sut) = makeSUT()

        let expectedResult: [Bet] = []

        service.completeLoadWith = { expectedResult }

        let bets = try await sut.updateBets()

        XCTAssertEqual(bets, expectedResult)
    }

    func test_updateBets_throwsErrorOnUpdateError() async throws {
        let (service, sut) = makeSUT()

        service.completeLoadWith = { throw self.anyError() }

        await XCTAssertThrowsError(try await sut.updateBets())
    }

    func test_updateBets_persistsChangesToBetsOnService() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Swift Bet", sellIn: 13, quality: 2)]

        service.completeLoadWith = { bets }

        let result = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Swift Bet", sellIn: 12, quality: 1)]

        XCTAssertEqual(service.bets, expectedBets)
        XCTAssertEqual(result, expectedBets)
    }

    func test_updateBets_doesNotUpdateServiceOnRetrievalError() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Swift Bet", sellIn: 13, quality: 2)]

        service.bets = bets

        service.completeLoadWith = { throw self.anyError()  }
        let result = try? await sut.updateBets()

        XCTAssertNil(result)
        XCTAssertEqual(service.bets, bets)
    }

    func test_updateBets_decreasesQualityOnPositiveQualityAndNon_PlayerPerformance_TotalScore_WinningTeam() async throws {
        let (service, sut) = makeSUT()

        let bets = [
            makeBet(name: "First goal scorer", sellIn: 10, quality: 49),
            makeBet(name: "Number of fouls", sellIn: 4, quality: 21),
            makeBet(name: "Set score", sellIn: 10, quality: 10)
        ]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "First goal scorer", sellIn: 9, quality: 48),
            makeBet(name: "Number of fouls", sellIn: 3, quality: 20),
            makeBet(name: "Set score", sellIn: 9, quality: 9)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doesNotDecreaseQualityOnNonPositiveQualityAndNon_PlayerPerformance_TotalScore_WinningTeam() async throws {
        let (service, sut) = makeSUT()

        let bets = [
            makeBet(name: "First goal scorer", sellIn: 10, quality: 1),
            makeBet(name: "Number of fouls", sellIn: 4, quality: 0),
            makeBet(name: "Set score", sellIn: 10, quality: -1)
        ]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "First goal scorer", sellIn: 9, quality: 0),
            makeBet(name: "Number of fouls", sellIn: 3, quality: 0),
            makeBet(name: "Set score", sellIn: 9, quality: -1)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_decreasesQualityTwiceOnQNegativeSellInAndNon_PlayerPerformance_TotalScore_WinningTeam() async throws {
        let (service, sut) = makeSUT()

        let bets = [
            makeBet(name: "First goal scorer", sellIn: 1, quality: 49),
            makeBet(name: "Number of fouls", sellIn: 0, quality: 21),
            makeBet(name: "Set score", sellIn: -1, quality: 10)
        ]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "First goal scorer", sellIn: 0, quality: 48),
            makeBet(name: "Number of fouls", sellIn: -1, quality: 19),
            makeBet(name: "Set score", sellIn: -2, quality: 8)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_increasesQualityOnQualityEqualOrGreaterThan50AndPlayerPerformance_TotalScore() async throws {
        let (service, sut) = makeSUT()

        let bets = [
            makeBet(name: "Total score", sellIn: 16, quality: 26),
            makeBet(name: "Player performance", sellIn: 9, quality: 4)
        ]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "Total score", sellIn: 15, quality: 27),
            makeBet(name: "Player performance", sellIn: 8, quality: 5)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_resetsQualityOnTotalScoreWithNegativeSellIn() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Total score", sellIn: -1, quality: 26)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Total score", sellIn: -2, quality: 0)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_increasesQualityTwiceOnTotalScoreWithSellInSmallerThan11() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Total score", sellIn: 10, quality: 10)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Total score", sellIn: 9, quality: 12)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doesNotIncreaseQualityTwiceOnTotalScoreWithSellInEqualOrGreaterThan50() async throws {
        let (service, sut) = makeSUT()

        let bets = [
            makeBet(name: "Total score", sellIn: 7, quality: 50),
            makeBet(name: "Total score", sellIn: 7, quality: 49),
            makeBet(name: "Total score", sellIn: 7, quality: 48)
        ]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "Total score", sellIn: 6, quality: 50),
            makeBet(name: "Total score", sellIn: 6, quality: 50),
            makeBet(name: "Total score", sellIn: 6, quality: 50)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doesNotIncreaseQualityThreeTimesOnTotalScoreWithSellInEqualOrGreaterThan50() async throws {
        let (service, sut) = makeSUT()

        let bets = [
            makeBet(name: "Total score", sellIn: 3, quality: 50),
            makeBet(name: "Total score", sellIn: 3, quality: 49),
            makeBet(name: "Total score", sellIn: 3, quality: 48),
            makeBet(name: "Total score", sellIn: 3, quality: 47)
        ]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "Total score", sellIn: 2, quality: 50),
            makeBet(name: "Total score", sellIn: 2, quality: 50),
            makeBet(name: "Total score", sellIn: 2, quality: 50),
            makeBet(name: "Total score", sellIn: 2, quality: 50)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_increasesQualityThreeTimesOnTotalScoreWithSellInSmallerThan6() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Total score", sellIn: 5, quality: 10)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Total score", sellIn: 4, quality: 13)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_increasesQualityTwiceOnTotalScoreWithSellInEqualOrGreaterThan6() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Total score", sellIn: 6, quality: 10)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Total score", sellIn: 5, quality: 12)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_increasesQualityOnceOnTotalScoreWithSellInEqualOrGreaterThan11() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Total score", sellIn: 11, quality: 10)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Total score", sellIn: 10, quality: 11)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_increasesQualityTwiceOnPlayerPerformanceWithNegativeSellIn() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Player performance", sellIn: -1, quality: 26)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "Player performance", sellIn: -2, quality: 28)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doesNothingOnWinningTeamWithPositiveQualityAndPositiveSellIn() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Winning team", sellIn: 15, quality: 26)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Winning team", sellIn: 15, quality: 26)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doNothingOnWinningTeamWithNegativeQualityAndNegativeSellIn() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Winning team", sellIn: -2, quality: -1)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Winning team", sellIn: -2, quality: -1)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doNothingOnWinningTeamWithPositiveQualityAndNegativeSellIn() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Winning team", sellIn: -2, quality: 1)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Winning team", sellIn: -2, quality: 1)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doNothingOnWinningTeamWithNegativeQualityAndPositiveSellIn() async throws {
        let (service, sut) = makeSUT()

        let bets = [makeBet(name: "Winning team", sellIn: 2, quality: -1)]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [makeBet(name: "Winning team", sellIn: 2, quality: -1)]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doesNotIncreaseQualityGreaterThan50OnPlayerPerformanceWithSellInEqualOrGraterThan50() async throws {
        let (service, sut) = makeSUT()

        let bets = [
            makeBet(name: "Player performance", sellIn: -13, quality: 51),
            makeBet(name: "Player performance", sellIn: -25, quality: 50),
            makeBet(name: "Player performance", sellIn: -15, quality: 49),
            makeBet(name: "Player performance", sellIn: -46, quality: 48)
        ]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "Player performance", sellIn: -14, quality: 51),
            makeBet(name: "Player performance", sellIn: -26, quality: 50),
            makeBet(name: "Player performance", sellIn: -16, quality: 50),
            makeBet(name: "Player performance", sellIn: -47, quality: 50)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    func test_updateBets_doesNotDecreaseQualitySmallerThan0OnBetWithSellInEqualOrSmallerThan0() async throws {
        let (service, sut) = makeSUT()

        let bets = [
            makeBet(name: "First goal scorer", sellIn: -14, quality: 2),
            makeBet(name: "First goal scorer", sellIn: -13, quality: 1),
            makeBet(name: "First goal scorer", sellIn: -25, quality: 0),
            makeBet(name: "First goal scorer", sellIn: -15, quality: -1)
        ]

        service.completeLoadWith = { bets }
        let updatedBets = try await sut.updateBets()

        let expectedBets = [
            makeBet(name: "First goal scorer", sellIn: -15, quality: 0),
            makeBet(name: "First goal scorer", sellIn: -14, quality: 0),
            makeBet(name: "First goal scorer", sellIn: -26, quality: 0),
            makeBet(name: "First goal scorer", sellIn: -16, quality: -1)
        ]

        XCTAssertEqual(updatedBets, expectedBets)
    }

    // MARK: Helpers

    func makeSUT() -> (service: BetServiceSpy, sut: ServiceBetRepository) {
        let service = BetServiceSpy()
        let sut = ServiceBetRepository(service: service)

        return (service, sut)
    }

    func anyError() -> Error {
        NSError(domain: "any error", code: 0)
    }

    func makeBet(name: String, sellIn: Int, quality: Int) -> Bet {
        Bet(
            name: name,
            sellIn: sellIn,
            quality: quality
        )
    }
}

extension Bet: Equatable {
    public static func == (lhs: Bet, rhs: Bet) -> Bool {
        lhs.name == rhs.name && lhs.quality == rhs.quality && lhs.sellIn == rhs.sellIn
    }
}


extension XCTest {
    func XCTAssertThrowsError<T: Sendable>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
