import XCTest
@testable import Bets
import BetsCore

final class OddsViewControllerTests: XCTestCase {
    func test_updateOdds_showsActivityIndicatorOnUpdatingOdds() {
        let (viewModel, sut) = makeSUT()

        let expectation = XCTestExpectation(description: "Expecting update odds to finish successfully")

        viewModel.completeUpdateWith = { await Task.sleep(seconds: 1) }
        sut.updateOdds()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(sut.activity.isAnimating)
            XCTAssertTrue(sut.list.isHidden)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_updateOdds_doesNotShowActivityIndicatorAfterUpdatingOdds() {
        let (viewModel, sut) = makeSUT()

        let expectation = XCTestExpectation(description: "Expecting update odds to finish successfully")

        viewModel.completeUpdateWith = { await Task.sleep(seconds: 0.25) }
        sut.updateOdds()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(sut.activity.isAnimating)
            XCTAssertFalse(sut.list.isHidden)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func test_updateOdds_showsEmptyListOnEmptyOdds() {
        let (viewModel, sut) = makeSUT()

        viewModel.odds = []

        XCTAssertEqual(sut.list.numberOfItems(inSection: 0), 0)
    }

    func test_updateOdds_showsListOnNonEmptyOdds() {
        let (viewModel, sut) = makeSUT()

        let odds = [
            Bet(name: "Offsides", sellIn: 6, quality: 12),
            Bet(name: "Penalties", sellIn: 2, quality: 52),
            Bet(name: "Half-time score", sellIn: 6, quality: 22)
        ]

        viewModel.odds = odds

        XCTAssertEqual(sut.list.numberOfItems(inSection: 0), odds.count)
    }

    // MARK: Helpers

    func makeSUT() -> (viewModel: OddsViewModelSpy, sut: OddsViewController) {
        let viewModel = OddsViewModelSpy()

        let sut = OddsViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()

        return (viewModel, sut)
    }

    class OddsViewModelSpy: OddsViewModel {
        var odds = [Bet]()

        var completeUpdateWith: (() async throws -> Void)?

        func updateOdds() async throws {
            guard let completeUpdateWith = completeUpdateWith else { return }

            return try await completeUpdateWith()
        }
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


extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
