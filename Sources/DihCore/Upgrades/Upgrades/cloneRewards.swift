import Foundation

public extension DihUpgradeDefinition {
  static let cloneRewards = DihUpgradeDefinition(
    id: .cloneRewards,
    name: "Clone Rewards",
    description: "Clone catches pay more.",
    icon: "gift.fill",
    baseCost: 40,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Catch in a clone window",
    tier: .advanced,
    prerequisites: [],
    minimumCatches: 30,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.cloneRewards.rawValue] = level
      return "Clone reward: \(DihEconomy.cloneRewardMultiplier(in: projectedSave))x"
    }
  )
}
