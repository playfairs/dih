import Foundation

public extension DihUpgradeDefinition {
  static let cloneCapacity = DihUpgradeDefinition(
    id: .cloneCapacity,
    name: "Clone Capacity",
    description: "Allows more clone windows.",
    icon: "rectangle.stack.badge.plus",
    baseCost: 30,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Clone Discount Lv. 2",
    tier: .advanced,
    prerequisites: [(.cloneDiscount, 2)],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.cloneCapacity.rawValue] = level
      return "Clone limit: \(DihEconomy.cloneLimit(in: projectedSave))"
    }
  )
}
