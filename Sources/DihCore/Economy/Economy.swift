import Foundation

public enum DihEconomy {
  public static let maximumOfflineDuration: TimeInterval = 8 * 60 * 60
  public static let maximumCloneWindows = 3
  public static let helperPurchaseBaseCost = 100
  public static let helperCostGrowthRate = 1.10
  public static let helperCostGrowthLimit = 60
  public static let helperBasePointsPerUnit = 1.0

  public static func level(for upgrade: DihUpgradeID, in save: DihSaveData) -> Int {
    save.upgrades[upgrade.rawValue, default: 0]
  }

  public static func cost(for upgrade: DihUpgradeID, level: Int) -> Int {
    let definition = DihUpgradeDefinition.definition(for: upgrade)
    let boundedLevel = min(max(0, level), DihUpgradeConstants.defaultMaximumLevel)
    let growth = max(1.0, 1.0 + definition.costGrowthRate)
    let rawCost = Double(definition.baseCost) * pow(growth, Double(boundedLevel))
    let safeCost = min(rawCost, Double(Int.max))
    return max(1, Int(ceil(safeCost)))
  }

  public static func cost(for upgrade: DihUpgradeID, fromLevel: Int, quantity: Int) -> Int {
    guard quantity > 0 else { return 0 }
    var total = 0
    let limit = min(max(0, quantity), DihUpgradeConstants.defaultMaximumLevel)
    let definition = DihUpgradeDefinition.definition(for: upgrade)
    let remainingToMax = definition.maximumLevel - fromLevel
    let buyable = min(limit, max(0, remainingToMax))
    guard buyable > 0 else { return 0 }
    for offset in 0..<buyable {
      total += cost(for: upgrade, level: fromLevel + offset)
    }
    return total
  }

  public static func cost(for upgrade: DihUpgradeID, quantity: Int, in save: DihSaveData) -> Int {
    cost(for: upgrade, fromLevel: level(for: upgrade, in: save), quantity: quantity)
  }

  public static func maxAffordable(for upgrade: DihUpgradeID, level: Int, points: Int) -> Int {
    let definition = DihUpgradeDefinition.definition(for: upgrade)
    var affordable = 0
    var remaining = max(0, points)
    var probe = level
    while affordable < definition.maximumLevel - level && remaining >= cost(for: upgrade, level: probe) {
      let price = cost(for: upgrade, level: probe)
      remaining -= price
      affordable += 1
      probe += 1
    }
    return affordable
  }

  public static func maxAffordable(for upgrade: DihUpgradeID, in save: DihSaveData) -> Int {
    maxAffordable(for: upgrade, level: level(for: upgrade, in: save), points: save.points)
  }

  @discardableResult
  public static func purchase(
    _ upgrade: DihUpgradeID, quantity: Int = 1, in save: inout DihSaveData
  ) -> Int {
    let definition = DihUpgradeDefinition.definition(for: upgrade)
    let currentLevel = level(for: upgrade, in: save)
    guard quantity > 0 else { return 0 }
    guard currentLevel < definition.maximumLevel else { return 0 }
    let affordableQuantity = maxAffordable(for: upgrade, level: currentLevel, points: save.points)
    let buyableQuantity = min(quantity, definition.maximumLevel - currentLevel, affordableQuantity)
    guard buyableQuantity > 0 else { return 0 }

    let totalCost = cost(for: upgrade, fromLevel: currentLevel, quantity: buyableQuantity)
    guard totalCost <= save.points else { return 0 }
    save.points -= totalCost
    save.upgrades[upgrade.rawValue, default: 0] = currentLevel + buyableQuantity
    return buyableQuantity
  }

  public static func helperCost(forOwned owned: Int) -> Int {
    let n = max(0, owned)
    let boundedOwned = min(n, helperCostGrowthLimit)
    let raw = Double(helperPurchaseBaseCost) * pow(helperCostGrowthRate, Double(boundedOwned))
    guard raw.isFinite else { return Int.max }
    let normalized = raw - 1e-6
    guard normalized <= Double(Int.max) else { return Int.max }
    return max(1, Int(ceil(normalized)))
  }

  public static func helperIncomePerHelper(in save: DihSaveData) -> Double {
    guard save.ownedHelpers > 0 else { return 0.0 }

    let efficiencyLevel = level(for: .hotlineEfficiency, in: save)
    let efficiencyModifier = Double(efficiencyLevel + 1)

    let adviceModifier = 1.0 + Double(level(for: .betterAdvice, in: save)) * 0.10
    let automationModifier = 1.0 + Double(level(for: .automatedHotline, in: save)) * 0.35
    let multiplierModifier = 1.0 + Double(level(for: .hotlineMultiplier, in: save)) * 0.50

    return helperBasePointsPerUnit * efficiencyModifier * adviceModifier
      * automationModifier * multiplierModifier
  }

  public static func totalPassiveIncome(in save: DihSaveData) -> Double {
    let helperCount = Double(max(0, save.ownedHelpers))
    return helperCount * helperIncomePerHelper(in: save)
  }

  public static func awardPassivePayout(in save: inout DihSaveData, generated: Int) -> Int {
    let amount = max(0, generated)
    save.points += amount
    save.totalPointsEarned += amount
    save.passivePointsGenerated += amount
    return amount
  }

  public static func isUnlocked(_ upgrade: DihUpgradeID, in save: DihSaveData) -> Bool {
    let definition = DihUpgradeDefinition.definition(for: upgrade)
    guard save.totalCatches >= definition.minimumCatches,
      save.totalPointsEarned >= definition.minimumPoints,
      definition.prerequisites.allSatisfy({ level(for: $0.0, in: save) >= $0.1 })
    else { return false }
    if upgrade == .hotlineEfficiency || upgrade == .fasterHotline || upgrade == .betterAdvice
      || upgrade == .dedicatedOperator || upgrade == .automatedHotline
      || upgrade == .hotlineMultiplier
    {
      return save.ownedHelpers > 0
    }
    if upgrade == .cloneDiscount { return save.totalCloneWindowsOpened > 0 }
    if upgrade == .cloneRewards || upgrade == .cloneCapacity {
      return save.totalCloneWindowsOpened > 0
    }
    return true
  }

  public static func pointsPerCatch(in save: DihSaveData) -> Int {
    Int(ceil(Double(1 + level(for: .quickHands, in: save)) * pointMultiplier(in: save)))
  }

  public static func bonusChance(in save: DihSaveData) -> Double {
    min(0.8, Double(level(for: .luckyDih, in: save)) * 0.04 * arcadeLuck(in: save))
  }

  public static func runAwayChance(in save: DihSaveData) -> Double {
    let gripReduction = Double(level(for: .betterGrip, in: save)) * 0.045
    let escapeReduction = Double(level(for: .escapePrediction, in: save)) * 0.05
    let reflexReduction = Double(level(for: .reflexes, in: save)) * 0.04
    let slowerReduction = Double(level(for: .slowerDih, in: save)) * 0.03
    return max(0.06, 0.62 - gripReduction - escapeReduction - reflexReduction - slowerReduction)
  }

  public static func targetScale(in save: DihSaveData) -> Double {
    (1 + Double(level(for: .biggerTarget, in: save)) * 0.08) * cloneTargetMultiplier(in: save)
  }

  public static func effectiveTargetScale(in save: DihSaveData, largerButton: Bool) -> Double {
    targetScale(in: save) * catchRadiusMultiplier(in: save) * (largerButton ? 1.25 : 1)
  }

  public static func passivePointsPerInterval(in save: DihSaveData) -> Int {
    Int(ceil(totalPassiveIncome(in: save)))
  }

  public static func passiveInterval(in save: DihSaveData) -> TimeInterval {
    let base = 14.0
    let fast = Double(level(for: .fasterHotline, in: save)) * 0.45
    let automated = Double(level(for: .automatedHotline, in: save)) * 0.5
    return max(3, base - fast - automated)
  }

  public static func comboBonus(in save: DihSaveData) -> Int {
    guard save.currentStreak > 1 else { return 0 }
    let levelBonus = level(for: .combo, in: save) + level(for: .comboTraining, in: save)
    return Int(
      Double(save.currentStreak - 1) * Double(levelBonus) * 0.1 * streakMultiplier(in: save))
  }

  public static func cloneLimit(in save: DihSaveData) -> Int {
    maximumCloneWindows + level(for: .cloneCapacity, in: save) + level(
      for: .cloneDiscount, in: save) / 2
  }

  public static func cloneChance(in save: DihSaveData) -> Int {
    max(8, 20 - level(for: .cloneDiscount, in: save) * 2)
  }

  public static func movementDelay(in save: DihSaveData) -> TimeInterval {
    0.2 + Double(level(for: .stickyButton, in: save)) * 0.12
  }

  public static func catchRadiusMultiplier(in save: DihSaveData) -> Double {
    1 + Double(level(for: .magnetHands, in: save)) * 0.06
  }

  public static func passiveMultiplier(in save: DihSaveData) -> Double {
    1 + Double(level(for: .betterAdvice, in: save)) * 0.1 + Double(
      level(for: .automatedHotline, in: save)) * 0.25 + Double(
        level(for: .hotlineMultiplier, in: save)) * 0.5
  }

  public static func offlineDuration(in save: DihSaveData) -> TimeInterval {
    maximumOfflineDuration + Double(level(for: .dedicatedOperator, in: save)) * 2 * 60 * 60
  }

  public static func cloneRewardMultiplier(in save: DihSaveData) -> Int {
    1 + level(for: .cloneRewards, in: save) + level(for: .cloneMultiplier, in: save) * 2
  }

  public static func cloneTargetMultiplier(in save: DihSaveData) -> Double {
    1 + Double(level(for: .cloneCoordination, in: save)) * 0.1
  }

  public static func criticalChance(in save: DihSaveData) -> Double {
    min(0.35, Double(level(for: .criticalCatch, in: save)) * 0.015 * arcadeLuck(in: save))
  }

  public static func pointMultiplier(in save: DihSaveData) -> Double {
    1 + Double(level(for: .pointMultiplier, in: save)) * 0.15
  }

  public static func streakMultiplier(in save: DihSaveData) -> Double {
    1 + Double(level(for: .streakMastery, in: save)) * 0.12
  }

  public static func goldenChance(in save: DihSaveData) -> Double {
    min(0.2, Double(level(for: .goldenDih, in: save)) * 0.01 * arcadeLuck(in: save))
  }

  public static func secondChance(in save: DihSaveData) -> Double {
    Double(level(for: .secondChance, in: save)) * 0.1
  }

  public static func arcadeLuck(in save: DihSaveData) -> Double {
    1 + Double(level(for: .arcadeLuck, in: save)) * 0.2
  }

  public static func autonomousMovementChance(in save: DihSaveData) -> Double {
    max(
      0.015,
      0.14 - Double(level(for: .slowerDih, in: save)) * 0.02 - Double(
        level(for: .betterGrip, in: save)) * 0.008)
  }
}
