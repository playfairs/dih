import Foundation

public enum DihEconomy {
    public static let maximumOfflineDuration: TimeInterval = 8 * 60 * 60
    public static let maximumCloneWindows = 3

    public static func level(for upgrade: DihUpgradeID, in save: DihSaveData) -> Int {
        save.upgrades[upgrade.rawValue, default: 0]
    }

    public static func cost(for upgrade: DihUpgradeID, level: Int) -> Int {
        let definition = DihUpgradeDefinition.definition(for: upgrade)
        return max(1, Int(ceil(Double(definition.baseCost) * pow(definition.growth, Double(level)))))
    }

    public static func isUnlocked(_ upgrade: DihUpgradeID, in save: DihSaveData) -> Bool {
        let definition = DihUpgradeDefinition.definition(for: upgrade)
        guard save.totalCatches >= definition.minimumCatches,
              save.totalPointsEarned >= definition.minimumPoints,
              definition.prerequisites.allSatisfy({ level(for: $0.0, in: save) >= $0.1 }) else { return false }
        if upgrade == .hotlineEfficiency || upgrade == .fasterHotline { return save.helperActive }
        if upgrade == .cloneDiscount { return save.totalCloneWindowsOpened > 0 }
        if upgrade == .cloneRewards || upgrade == .cloneCapacity { return save.totalCloneWindowsOpened > 0 }
        return true
    }

    public static func pointsPerCatch(in save: DihSaveData) -> Int {
        Int(ceil(Double(1 + level(for: .quickHands, in: save)) * pointMultiplier(in: save)))
    }

    public static func bonusChance(in save: DihSaveData) -> Double {
        min(0.8, Double(level(for: .luckyDih, in: save)) * 0.04 * arcadeLuck(in: save))
    }

    public static func runAwayChance(in save: DihSaveData) -> Double {
        max(0.06, 0.62 - Double(level(for: .betterGrip, in: save)) * 0.045 - Double(level(for: .escapePrediction, in: save)) * 0.05 - Double(level(for: .reflexes, in: save)) * 0.04 - Double(level(for: .slowerDih, in: save)) * 0.03)
    }

    public static func targetScale(in save: DihSaveData) -> Double {
        (1 + Double(level(for: .biggerTarget, in: save)) * 0.08) * cloneTargetMultiplier(in: save)
    }

    public static func passivePointsPerInterval(in save: DihSaveData) -> Int {
        Int(ceil(Double(1 + level(for: .hotlineEfficiency, in: save)) * passiveMultiplier(in: save)))
    }

    public static func passiveInterval(in save: DihSaveData) -> TimeInterval {
        max(3, 14 - Double(level(for: .fasterHotline, in: save)) - Double(level(for: .automatedHotline, in: save)) * 0.5)
    }

    public static func comboBonus(in save: DihSaveData) -> Int {
        guard save.currentStreak > 1 else { return 0 }
        let levelBonus = level(for: .combo, in: save) + level(for: .comboTraining, in: save)
        return Int(Double(save.currentStreak - 1) * Double(levelBonus) * 0.1 * streakMultiplier(in: save))
    }

    public static func cloneLimit(in save: DihSaveData) -> Int {
        maximumCloneWindows + level(for: .cloneCapacity, in: save) + level(for: .cloneDiscount, in: save) / 2
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
        1 + Double(level(for: .betterAdvice, in: save)) * 0.1 + Double(level(for: .automatedHotline, in: save)) * 0.25 + Double(level(for: .hotlineMultiplier, in: save)) * 0.5
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
        max(0.015, 0.14 - Double(level(for: .slowerDih, in: save)) * 0.02 - Double(level(for: .betterGrip, in: save)) * 0.008)
    }
}