import Foundation

public extension DihUpgradeDefinition {
  static let luckyDih = DihUpgradeDefinition(
    id: .luckyDih,
    name: "Lucky Dih",
    description: "Adds a chance for bonus points.",
    icon: "sparkles",
    baseCost: 18,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Catch 20 buttons",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 20,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.luckyDih.rawValue] = level
      return "Bonus chance: \(Int(DihEconomy.bonusChance(in: projectedSave) * 100))%"
    }
  )
}
