import Foundation

public extension DihUpgradeDefinition {
  static let cloneMultiplier = DihUpgradeDefinition(
    id: .cloneMultiplier,
    name: "Clone Multiplier",
    description: "Multiplies clone rewards.",
    icon: "square.3.layers.3d",
    baseCost: 100,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Clone Coordination Lv. 2",
    tier: .elite,
    prerequisites: [(.cloneCoordination, 2)],
    minimumCatches: 0,
    minimumPoints: 1000,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.cloneMultiplier.rawValue] = level
      return "Clone reward: \(DihEconomy.cloneRewardMultiplier(in: projectedSave))x"
    }
  )
}
