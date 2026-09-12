import Foundation

public extension DihUpgradeDefinition {
  static let combo = DihUpgradeDefinition(
    id: .combo,
    name: "Combo",
    description: "Long streaks add extra points.",
    icon: "flame.fill",
    baseCost: 25,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Combo Training Lv. 2",
    tier: .advanced,
    prerequisites: [(.comboTraining, 2)],
    minimumCatches: 20,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.combo.rawValue] = level
      return "Current streak bonus: +\(DihEconomy.comboBonus(in: projectedSave))"
    }
  )
}
