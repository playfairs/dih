import Foundation

public extension DihUpgradeDefinition {
  static let cloneDiscount = DihUpgradeDefinition(
    id: .cloneDiscount,
    name: "Clone Discount",
    description: "Clones appear more often.",
    icon: "square.on.square",
    baseCost: 10,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Open a clone window",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.cloneDiscount.rawValue] = level
      return "Clone chance: 1 in \(DihEconomy.cloneChance(in: projectedSave))"
    }
  )
}
