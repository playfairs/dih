import Foundation

public extension DihUpgradeDefinition {
  static let biggerTarget = DihUpgradeDefinition(
    id: .biggerTarget,
    name: "Bigger Target",
    description: "Makes the target more forgiving.",
    icon: "arrow.up.left.and.arrow.down.right",
    baseCost: 10,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.biggerTargetMaximumLevel,
    unlockText: "Available immediately",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.biggerTarget.rawValue] = level
      return "Target size: \(Int(DihEconomy.targetScale(in: projectedSave) * 100))%"
    }
  )
}
