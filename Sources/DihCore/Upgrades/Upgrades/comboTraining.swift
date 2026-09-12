import Foundation

public extension DihUpgradeDefinition {
  static let comboTraining = DihUpgradeDefinition(
    id: .comboTraining,
    name: "Combo Training",
    description: "Improves streak rewards.",
    icon: "figure.run",
    baseCost: 32,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Catch 10 buttons",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 10,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.comboTraining.rawValue] = level
      return "Streak bonus: +\(DihEconomy.comboBonus(in: projectedSave))"
    }
  )
}
