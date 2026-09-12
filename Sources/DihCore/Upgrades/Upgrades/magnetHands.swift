import Foundation

public extension DihUpgradeDefinition {
  static let magnetHands = DihUpgradeDefinition(
    id: .magnetHands,
    name: "Magnet Hands",
    description: "Expands the effective clickable area.",
    icon: "scope",
    baseCost: 18,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Bigger Target Lv. 2",
    tier: .basic,
    prerequisites: [(.biggerTarget, 2)],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.magnetHands.rawValue] = level
      return "Target size: \(Int(DihEconomy.catchRadiusMultiplier(in: projectedSave) * 100))%"
    }
  )
}
