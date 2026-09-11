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
        switch upgrade {
        case .hotlineEfficiency, .fasterHotline:
            save.helperActive
        case .cloneDiscount:
            save.totalCloneWindowsOpened > 0
        case .escapePrediction:
            save.totalCatches >= 15
        case .luckyDih:
            save.totalCatches >= 20
        case .combo:
            save.totalCatches >= 10
        default:
            true
        }
    }

    public static func pointsPerCatch(in save: DihSaveData) -> Int {
        1 + level(for: .quickHands, in: save)
    }

    public static func bonusChance(in save: DihSaveData) -> Double {
        Double(level(for: .luckyDih, in: save)) * 0.04
    }

    public static func runAwayChance(in save: DihSaveData) -> Double {
        max(0.12, 0.62 - Double(level(for: .betterGrip, in: save)) * 0.045 - Double(level(for: .escapePrediction, in: save)) * 0.05)
    }

    public static func targetScale(in save: DihSaveData) -> Double {
        1 + Double(level(for: .biggerTarget, in: save)) * 0.08
    }

    public static func passivePointsPerInterval(in save: DihSaveData) -> Int {
        1 + level(for: .hotlineEfficiency, in: save)
    }

    public static func passiveInterval(in save: DihSaveData) -> TimeInterval {
        max(4, 14 - Double(level(for: .fasterHotline, in: save)))
    }

    public static func comboBonus(in save: DihSaveData) -> Int {
        guard save.currentStreak > 1 else { return 0 }
        return Int(Double(save.currentStreak - 1) * Double(level(for: .combo, in: save)) * 0.1)
    }

    public static func cloneLimit(in save: DihSaveData) -> Int {
        maximumCloneWindows + level(for: .cloneDiscount, in: save) / 2
    }

    public static func cloneChance(in save: DihSaveData) -> Int {
        max(8, 20 - level(for: .cloneDiscount, in: save) * 2)
    }
}