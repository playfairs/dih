import XCTest

@testable import DihCore

final class DihCoreTests: XCTestCase {
  func testDefaultCatchRewardAndUpgradeCost() {
    var save = DihSaveData()
    XCTAssertEqual(DihEconomy.pointsPerCatch(in: save), 1)
    XCTAssertEqual(DihEconomy.cost(for: .quickHands, level: 0), 12)

    save.upgrades[DihUpgradeID.quickHands.rawValue] = 2
    XCTAssertEqual(DihEconomy.pointsPerCatch(in: save), 3)
    XCTAssertGreaterThan(DihEconomy.cost(for: .quickHands, level: 2), 12)
  }

  func testLockedUpgradesAndPassiveBalance() {
    var save = DihSaveData()
    XCTAssertFalse(DihEconomy.isUnlocked(.hotlineEfficiency, in: save))
    save.ownedHelpers = 1
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

  func testHelperPurchaseCostSequenceAndOwnerCount() {
    XCTAssertEqual(DihEconomy.helperCost(forOwned: 0), 100)
    XCTAssertEqual(DihEconomy.helperCost(forOwned: 1), 110)
    XCTAssertEqual(DihEconomy.helperCost(forOwned: 2), 121)
    XCTAssertEqual(DihEconomy.helperCost(forOwned: 3), 134)

    var save = DihSaveData()
    save.points = 1_000_000

    let firstCost = DihEconomy.helperCost(forOwned: save.ownedHelpers)
    XCTAssertEqual(firstCost, 100)
    save.points -= firstCost
    save.ownedHelpers += 1
    XCTAssertEqual(save.ownedHelpers, 1)

    let secondCost = DihEconomy.helperCost(forOwned: save.ownedHelpers)
    XCTAssertEqual(secondCost, 110)
    save.points -= secondCost
    save.ownedHelpers += 1
    XCTAssertEqual(save.ownedHelpers, 2)

    let thirdCost = DihEconomy.helperCost(forOwned: save.ownedHelpers)
    XCTAssertEqual(thirdCost, 121)
    save.points -= thirdCost
    save.ownedHelpers += 1
    XCTAssertEqual(save.ownedHelpers, 3)
  }

  func testHelperCostSaturatesWhenOwnedHelperCountOverflowsTheGrowthSeries() {
    let futureCost = DihEconomy.helperCost(forOwned: 2_523)
    let cappedCost = DihEconomy.helperCost(forOwned: DihEconomy.helperCostGrowthLimit)
    XCTAssertEqual(futureCost, cappedCost)
  }

  func testUpgradeDefinitionsExposeSensibleMaximumLevelsForFiniteEffects() {
    XCTAssertEqual(DihUpgradeDefinition.definition(for: .fasterHotline).maximumLevel, 15)
    XCTAssertEqual(DihUpgradeDefinition.definition(for: .dedicatedOperator).maximumLevel, 4)
    XCTAssertEqual(DihUpgradeDefinition.definition(for: .automatedHotline).maximumLevel, 10)
    XCTAssertEqual(DihUpgradeDefinition.definition(for: .cloneCapacity).maximumLevel, 3)
  }

  func testHelperProductionUsesOwnedHelpersOnlyAndNeverLevelZeroBase() {
    let noHelpers = DihSaveData()
    XCTAssertEqual(DihEconomy.totalPassiveIncome(in: noHelpers), 0)

    var withOne = DihSaveData()
    withOne.ownedHelpers = 1
    XCTAssertEqual(DihEconomy.totalPassiveIncome(in: withOne), 1)

    var withTwo = DihSaveData()
    withTwo.ownedHelpers = 2
    XCTAssertEqual(DihEconomy.totalPassiveIncome(in: withTwo), 2)

    var withUpgrade = DihSaveData()
    withUpgrade.ownedHelpers = 2
    withUpgrade.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = 1
    let oneLevel = DihEconomy.helperIncomePerHelper(in: withUpgrade)
    XCTAssertGreaterThan(oneLevel, 1)
  }

  func testHelperEfficiencyUpgradeDoublesAllOwnedHelpers() {
    var save = DihSaveData()
    save.ownedHelpers = 5

    let before = DihEconomy.totalPassiveIncome(in: save)
    save.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = 1
    let after = DihEconomy.totalPassiveIncome(in: save)

    XCTAssertEqual(after, before * 2, accuracy: 0.0001)
  }

  func testHotlineEfficiencyLevelGrowthIsLevelIdentityMultiplier() {
    let definition = DihUpgradeDefinition.definition(for: .hotlineEfficiency)
    let levelOne = Double(definition.baseEffect)
    let levelTwo = Double(3)
    let levelFive = Double(5)

    XCTAssertEqual(levelOne, 1.0)
    XCTAssertEqual(levelTwo, 3)
    XCTAssertEqual(levelFive, 5)
  }

  func testHotlineEfficiencyProgressionIsLinearAcrossOwnedHelpers() {
    var save = DihSaveData()
    save.ownedHelpers = 2

    let level0 = DihEconomy.totalPassiveIncome(in: save)
    XCTAssertEqual(level0, 2, accuracy: 0.0001)

    save.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = 1
    let level1 = DihEconomy.totalPassiveIncome(in: save)
    XCTAssertEqual(level1, 4, accuracy: 0.0001)

    save.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = 2
    let level2 = DihEconomy.totalPassiveIncome(in: save)
    XCTAssertEqual(level2, 6, accuracy: 0.0001)

    save.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = 3
    let level3 = DihEconomy.totalPassiveIncome(in: save)
    XCTAssertEqual(level3, 8, accuracy: 0.0001)

    var five = DihSaveData()
    five.ownedHelpers = 5
    XCTAssertEqual(DihEconomy.totalPassiveIncome(in: five), 5, accuracy: 0.0001)

    five.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = 1
    XCTAssertEqual(DihEconomy.totalPassiveIncome(in: five), 10, accuracy: 0.0001)

    five.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = 2
    XCTAssertEqual(DihEconomy.totalPassiveIncome(in: five), 15, accuracy: 0.0001)
  }

  func testPassivePayoutAddsTheSameAmountThatEconomyCalculates() {
    var save = DihSaveData()
    save.ownedHelpers = 2
    save.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = 2

    let beforePoints = save.points
    let payout = DihEconomy.passivePointsPerInterval(in: save)
    XCTAssertEqual(payout, 6)

    let generated = DihEconomy.awardPassivePayout(in: &save, generated: payout)
    XCTAssertEqual(generated, 6)
    XCTAssertEqual(save.points, beforePoints + 6)
  }

  func testOfflinePayoutIsCapped() {
    XCTAssertEqual(DihEconomy.maximumOfflineDuration, 8 * 60 * 60)
    let save = DihSaveData()
    let payouts = Int(DihEconomy.maximumOfflineDuration / DihEconomy.passiveInterval(in: save))
    XCTAssertEqual(payouts, 2057)
  }

  func testTOMLPersistenceRoundTrip() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let saveURL = directory.appendingPathComponent("save.toml")
    let persistence = DihPersistence(fileURL: saveURL)
    var save = DihSaveData()
    save.points = 42
    save.totalCatches = 12
    save.upgrades[DihUpgradeID.quickHands.rawValue] = 2

    await persistence.save(save)
    let loaded = await persistence.load()
    let toml = try String(contentsOf: await persistence.saveURL(), encoding: .utf8)

    XCTAssertEqual(loaded.points, 42)
    XCTAssertEqual(loaded.totalCatches, 12)
    XCTAssertEqual(loaded.upgrades[DihUpgradeID.quickHands.rawValue], 2)
    XCTAssertTrue(toml.contains("[game]"))
    XCTAssertTrue(toml.contains("[helpers]"))
    XCTAssertTrue(toml.contains("[prestige]"))
    XCTAssertTrue(toml.contains("[statistics]"))
    XCTAssertTrue(toml.contains("[settings]"))
    XCTAssertTrue(toml.contains("quick_hands = 2"))
    await persistence.deleteSave()
  }

  func testArenaAlwaysKeepsEntireButtonInsideBounds() {
    let arena = CGRect(x: 0, y: 0, width: 420, height: 260)
    let button = CGSize(width: 140, height: 48)
    var generator = SystemRandomNumberGenerator()

    for _ in 0..<100 {
      let center = DihArena.randomCenter(in: arena, buttonSize: button, generator: &generator)
      let frame = CGRect(
        x: center.x - button.width / 2, y: center.y - button.height / 2, width: button.width,
        height: button.height)
      XCTAssertTrue(arena.contains(frame))
    }

    let clamped = DihArena.clampedCenter(
      in: arena, buttonSize: button, desired: CGPoint(x: -100, y: 999))
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

  func testBiggerTargetAndBetterGripRemainEffectfulAndCapped() {
    let biggerDef = DihUpgradeDefinition.definition(for: .biggerTarget)
    XCTAssertEqual(biggerDef.maximumLevel, DihUpgradeConstants.biggerTargetMaximumLevel)

    var save = DihSaveData()
    let baseGripEscape = DihEconomy.runAwayChance(in: save)
    let baseTargetScale = DihEconomy.targetScale(in: save)

    save.upgrades[DihUpgradeID.betterGrip.rawValue] = 1
    let gripAfterOne = DihEconomy.runAwayChance(in: save)
    XCTAssertLessThan(gripAfterOne, baseGripEscape)

    save.upgrades[DihUpgradeID.biggerTarget.rawValue] = 1
    let targetAfterOne = DihEconomy.targetScale(in: save)
    XCTAssertGreaterThan(targetAfterOne, baseTargetScale)

    let levelOneTarget = DihEconomy.targetScale(in: save)
    save.upgrades[DihUpgradeID.biggerTarget.rawValue] = DihUpgradeConstants.biggerTargetMaximumLevel
    let levelMaxTarget = DihEconomy.targetScale(in: save)
    XCTAssertGreaterThan(levelMaxTarget, levelOneTarget)
  }

  func testBiggerTargetChangesEffectiveTargetScaleThroughEconomyAPI() {
    var save = DihSaveData()
    let baseSize = DihEconomy.effectiveTargetScale(in: save, largerButton: false)

    save.upgrades[DihUpgradeID.biggerTarget.rawValue] = 1
    let upgradedSize = DihEconomy.effectiveTargetScale(in: save, largerButton: false)

    XCTAssertGreaterThan(upgradedSize, baseSize)
  }

  func testSettingsRoundTripIsSeparateFromGameSave() async {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let persistence = DihSettingsPersistence(
      fileURL: directory.appendingPathComponent("settings.toml"))
    var settings = DihSettingsData()
    settings.largerButton = true
    settings.maximumCloneWindows = 6

    await persistence.save(settings)
    let loaded = await persistence.load()
    let toml = try? String(
      contentsOf: directory.appendingPathComponent("settings.toml"), encoding: .utf8)

    XCTAssertTrue(loaded.largerButton)
    XCTAssertEqual(loaded.maximumCloneWindows, 6)
    XCTAssertTrue(toml?.contains("sound_effects_enabled") == true)
  }

  func testSettingsRoundTripSupportsAppearanceAndAchievementNotificationPreference() async {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let persistence = DihSettingsPersistence(
      fileURL: directory.appendingPathComponent("settings.toml"))
    var settings = DihSettingsData()
    settings.appearance = .dark
    settings.achievementNotificationsEnabled = false
    settings.largerButton = true

    await persistence.save(settings)
    let loaded = await persistence.load()
    let toml = try? String(
      contentsOf: directory.appendingPathComponent("settings.toml"), encoding: .utf8)

    XCTAssertEqual(loaded.appearance, .dark)
    XCTAssertFalse(loaded.achievementNotificationsEnabled)
    XCTAssertTrue(loaded.largerButton)
    XCTAssertTrue(toml?.contains("appearance = \"Dark\"") == true)
  }

  func testLegacySaveKeepsStatsWhenNewFieldsAreMissing() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let saveURL = directory.appendingPathComponent("save.json")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    var legacySave = DihSaveData()
    legacySave.points = 37
    legacySave.totalPointsEarned = 52
    legacySave.totalCatches = 19
    legacySave.totalAttempts = 24
    legacySave.upgrades[DihUpgradeID.quickHands.rawValue] = 1
    let legacyJSON = try JSONEncoder().encode(legacySave)
    try legacyJSON.write(to: saveURL)

    let loaded = await DihPersistence(fileURL: directory.appendingPathComponent("save.toml")).load()
    let migratedTOML = try String(
      contentsOf: directory.appendingPathComponent("save.toml"), encoding: .utf8)

    XCTAssertEqual(loaded.points, 37)
    XCTAssertEqual(loaded.totalCatches, 19)
    XCTAssertEqual(loaded.upgrades[DihUpgradeID.quickHands.rawValue], 1)
    XCTAssertTrue(migratedTOML.contains("[game]"))
    XCTAssertFalse(FileManager.default.fileExists(atPath: saveURL.path))
  }

  func testMalformedTOMLReturnsFreshStateSafely() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let saveURL = directory.appendingPathComponent("save.toml")
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    try Data("[game\npoints = nope".utf8).write(to: saveURL)

    let loaded = await DihPersistence(fileURL: saveURL).load()

    XCTAssertEqual(loaded.points, 0)
    XCTAssertEqual(loaded.totalCatches, 0)
  }

  func testUnsupportedTOMLVersionReturnsFreshStateSafely() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let persistence = DihPersistence(fileURL: directory.appendingPathComponent("save.toml"))
    await persistence.save(DihSaveData())
    let saveURL = await persistence.saveURL()
    var toml = try String(contentsOf: saveURL, encoding: .utf8)
    toml = toml.replacingOccurrences(of: "version = 2", with: "version = 999")
    try toml.write(to: saveURL, atomically: true, encoding: .utf8)

    let loaded = await persistence.load()

    XCTAssertEqual(loaded.points, 0)
    XCTAssertEqual(loaded.totalCatches, 0)
  }

}
