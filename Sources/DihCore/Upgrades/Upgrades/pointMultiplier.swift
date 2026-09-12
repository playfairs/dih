import Foundation

public extension DihUpgradeDefinition {
  static let pointMultiplier = DihUpgradeDefinition(
    id: .pointMultiplier,
    name: "Point Multiplier",
    description: "Increases all active catch rewards.",
    icon: "xmark.circle.fill",
    baseCost: 75,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Earn 1,000 lifetime points",
    tier: .expert,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 1000,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.pointMultiplier.rawValue] = level
      return "Catch multiplier: \(DihEconomy.pointMultiplier(in: projectedSave))x"
    }
  )
}
