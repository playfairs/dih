import Foundation

public extension DihUpgradeDefinition {
  static let dedicatedOperator = DihUpgradeDefinition(
    id: .dedicatedOperator,
    name: "Dedicated Operator",
    description: "Raises the offline earnings cap.",
    icon: "person.crop.circle.badge.checkmark",
    baseCost: 50,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Faster Hotline Lv. 3",
    tier: .expert,
    prerequisites: [(.fasterHotline, 3)],
    minimumCatches: 0,
    minimumPoints: 100,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.dedicatedOperator.rawValue] = level
      return "Offline cap: \(Int(DihEconomy.offlineDuration(in: projectedSave) / 3600))h"
    }
  )
}
