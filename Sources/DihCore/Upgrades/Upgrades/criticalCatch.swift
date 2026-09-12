import Foundation

public extension DihUpgradeDefinition {
  static let criticalCatch = DihUpgradeDefinition(
    id: .criticalCatch,
    name: "Critical Catch",
    description: "Rare catches pay a large bonus.",
    icon: "burst.fill",
    baseCost: 60,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Lucky Dih Lv. 3",
    tier: .expert,
    prerequisites: [(.luckyDih, 3)],
    minimumCatches: 0,
    minimumPoints: 250,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.criticalCatch.rawValue] = level
      return "Critical chance: \(Int(DihEconomy.criticalChance(in: projectedSave) * 100))%"
    }
  )
}
