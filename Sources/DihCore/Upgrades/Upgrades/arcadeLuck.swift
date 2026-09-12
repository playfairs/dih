import Foundation

public extension DihUpgradeDefinition {
  static let arcadeLuck = DihUpgradeDefinition(
    id: .arcadeLuck,
    name: "Arcade Luck",
    description: "Improves rare event odds.",
    icon: "dice.fill",
    baseCost: 125,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Earn 5,000 lifetime points",
    tier: .elite,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 5000,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.arcadeLuck.rawValue] = level
      return "Rare event odds: \(Int((DihEconomy.arcadeLuck(in: projectedSave) - 1) * 100))% better"
    }
  )
}
