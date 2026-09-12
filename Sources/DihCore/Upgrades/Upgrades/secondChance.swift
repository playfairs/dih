import Foundation

public extension DihUpgradeDefinition {
  static let secondChance = DihUpgradeDefinition(
    id: .secondChance,
    name: "Second Chance",
    description: "Sometimes protects your streak.",
    icon: "arrow.uturn.backward.circle.fill",
    baseCost: 70,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Reach a 25 catch streak",
    tier: .expert,
    prerequisites: [],
    minimumCatches: 25,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.secondChance.rawValue] = level
      return "Streak save: \(Int(DihEconomy.secondChance(in: projectedSave) * 100))%"
    }
  )
}
