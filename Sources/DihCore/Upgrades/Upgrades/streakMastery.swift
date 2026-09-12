import Foundation

public extension DihUpgradeDefinition {
  static let streakMastery = DihUpgradeDefinition(
    id: .streakMastery,
    name: "Streak Mastery",
    description: "Makes streaks more valuable.",
    icon: "chart.line.uptrend.xyaxis",
    baseCost: 90,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Reach a 25 catch streak",
    tier: .expert,
    prerequisites: [],
    minimumCatches: 25,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.streakMastery.rawValue] = level
      return "Streak multiplier: \(DihEconomy.streakMultiplier(in: projectedSave))x"
    }
  )
}
