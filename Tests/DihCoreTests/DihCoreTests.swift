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

    func testArenaAlwaysKeepsEntireButtonInsideBounds() {
        let arena = CGRect(x: 0, y: 0, width: 420, height: 260)
        let button = CGSize(width: 140, height: 48)
        var generator = SystemRandomNumberGenerator()

        for _ in 0..<100 {
            let center = DihArena.randomCenter(in: arena, buttonSize: button, generator: &generator)
            let frame = CGRect(x: center.x - button.width / 2, y: center.y - button.height / 2, width: button.width, height: button.height)
            XCTAssertTrue(arena.contains(frame))
        }

        let clamped = DihArena.clampedCenter(in: arena, buttonSize: button, desired: CGPoint(x: -100, y: 999))
        XCTAssertEqual(clamped, CGPoint(x: 70, y: 236))
    }

    func testUpgradePrerequisitesRemainLockedUntilMet() {
        var save = DihSaveData()
        save.totalCatches = 100
        XCTAssertFalse(DihEconomy.isUnlocked(.stickyButton, in: save))
        save.upgrades[DihUpgradeID.betterGrip.rawValue] = 2
        XCTAssertTrue(DihEconomy.isUnlocked(.stickyButton, in: save))
    }

    func testGameplayUpgradesChangeTheirRuntimeEffects() {
        var save = DihSaveData()
        let baseAutonomousChance = DihEconomy.autonomousMovementChance(in: save)
        let baseTargetScale = DihEconomy.targetScale(in: save)
        let baseRareChance = DihEconomy.bonusChance(in: save)

        save.upgrades[DihUpgradeID.slowerDih.rawValue] = 3
        save.upgrades[DihUpgradeID.cloneCoordination.rawValue] = 2
        save.upgrades[DihUpgradeID.arcadeLuck.rawValue] = 2
        save.upgrades[DihUpgradeID.luckyDih.rawValue] = 1

        XCTAssertLessThan(DihEconomy.autonomousMovementChance(in: save), baseAutonomousChance)
        XCTAssertGreaterThan(DihEconomy.targetScale(in: save), baseTargetScale)
        XCTAssertGreaterThan(DihEconomy.bonusChance(in: save), baseRareChance)
    }

    func testSettingsRoundTripIsSeparateFromGameSave() async {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let persistence = DihSettingsPersistence(fileURL: directory.appendingPathComponent("settings.json"))
        var settings = DihSettingsData()
        settings.largerButton = true
        settings.maximumCloneWindows = 6

        await persistence.save(settings)
        let loaded = await persistence.load()

        XCTAssertTrue(loaded.largerButton)
        XCTAssertEqual(loaded.maximumCloneWindows, 6)
    }

    func testLegacySaveKeepsStatsWhenNewFieldsAreMissing() async throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let saveURL = directory.appendingPathComponent("save.json")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let legacyJSON = """
        {"version":1,"points":37,"totalPointsEarned":52,"totalCatches":19,"totalAttempts":24,"bestScore":37,"currentStreak":3,"bestStreak":7,"totalTimePlayed":120,"passivePointsGenerated":4,"totalHotlineCalls":2,"totalCloneWindowsOpened":1,"cloneCatches":2,"totalEscapes":5,"upgrades":{"quickHands":1},"achievements":["firstCatch"],"helperActive":true}
        """
        try Data(legacyJSON.utf8).write(to: saveURL)

        let loaded = await DihPersistence(fileURL: saveURL).load()

        XCTAssertEqual(loaded.points, 37)
        XCTAssertEqual(loaded.totalCatches, 19)
        XCTAssertEqual(loaded.upgrades[DihUpgradeID.quickHands.rawValue], 1)
        XCTAssertEqual(loaded.totalOfflinePoints, 0)
    }
}
