//
//  BetsTests.swift
//  BetsTests
//
//  Created by Patrick Battisti Forsthofer on 24/04/23.
//

import XCTest
import BetsCore
@testable import Bets

final class OddsViewModelTests: XCTestCase {
    func test_updateOdds_callsRepository() async throws {
        let (repository, sut) = makeSUT()

        repository.completeUpdateWith = { [] }
        try? await sut.updateOdds()

        XCTAssertEqual(repository.events, [.update])
    }

    func test_updateOdds_retrievesBetsSortedBySellIn() async throws {
        let (repository, sut) = makeSUT()

        let bets = [
            makeBet(name: "First goal scorer", sellIn: 5, quality: 12),
            makeBet(name: "First goal scorer", sellIn: 18, quality: 34),
            makeBet(name: "First goal scorer", sellIn: 41, quality: 63),
            makeBet(name: "First goal scorer", sellIn: 51, quality: 12)
        ]

        repository.completeUpdateWith = { bets }
        try? await sut.updateOdds()

        let expectedBets = [
            makeBet(name: "First goal scorer", sellIn: 51, quality: 12),
            makeBet(name: "First goal scorer", sellIn: 41, quality: 63),
            makeBet(name: "First goal scorer", sellIn: 18, quality: 34),
            makeBet(name: "First goal scorer", sellIn: 5, quality: 12)
        ]

        XCTAssertEqual(sut.odds, expectedBets)
    }

    // MARK: Helpers

    func makeSUT() -> (repository: BetRepositorySpy, sut: any OddsViewModel) {
        let repository = BetRepositorySpy()

        let sut = OddsRepositoryViewModel(
            repository: repository,
            sortingStrategy: SellInOddsSortingStrategy()
        )

        return (repository, sut)
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
