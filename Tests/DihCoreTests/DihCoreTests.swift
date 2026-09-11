import XCTest
@testable import DihCore

final class DihCoreTests: XCTestCase {
    func testDefaultCatchRewardAndUpgradeCost() {
        var save = DihSaveData()
        XCTAssertEqual(DihEconomy.pointsPerCatch(in: save), 1)
        XCTAssertEqual(DihEconomy.cost(for: .quickHands, level: 0), 12)

        save.upgrades[ DihUpgradeID.quickHands.rawValue ] = 2
        XCTAssertEqual(DihEconomy.pointsPerCatch(in: save), 3)
        XCTAssertGreaterThan(DihEconomy.cost(for: .quickHands, level: 2), 12)
    }

    func testLockedUpgradesAndPassiveBalance() {
        var save = DihSaveData()
        XCTAssertFalse(DihEconomy.isUnlocked(.hotlineEfficiency, in: save))
        save.helperActive = true
        XCTAssertTrue(DihEconomy.isUnlocked(.hotlineEfficiency, in: save))
        XCTAssertEqual(DihEconomy.passivePointsPerInterval(in: save), 1)
        XCTAssertEqual(DihEconomy.passiveInterval(in: save), 14)
    }

    func testInsufficientFundsCannotBuyByEconomyRules() {
        var save = DihSaveData()
        let price = DihEconomy.cost(for: .betterGrip, level: 0)
        XCTAssertGreaterThan(price, save.points)
        save.points = price - 1
        XCTAssertLessThan(save.points, price)
    }

    func testOfflinePayoutIsCapped() {
        XCTAssertEqual(DihEconomy.maximumOfflineDuration, 8 * 60 * 60)
        let save = DihSaveData()
        let payouts = Int(DihEconomy.maximumOfflineDuration / DihEconomy.passiveInterval(in: save))
        XCTAssertEqual(payouts, 2057)
    }

    func testPersistenceRoundTrip() async {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let saveURL = directory.appendingPathComponent("save.json")
        let persistence = DihPersistence(fileURL: saveURL)
        var save = DihSaveData()
        save.points = 42
        save.totalCatches = 12
        save.upgrades[DihUpgradeID.quickHands.rawValue] = 2

        await persistence.save(save)
        let loaded = await persistence.load()

        XCTAssertEqual(loaded.points, 42)
        XCTAssertEqual(loaded.totalCatches, 12)
        XCTAssertEqual(loaded.upgrades[DihUpgradeID.quickHands.rawValue], 2)
        await persistence.deleteSave()
    }
}
