import Foundation

public extension DihUpgradeDefinition {
  static let goldenDih = DihUpgradeDefinition(
    id: .goldenDih,
    name: "Golden Dih",
    description: "Unlocks rare golden catches.",
    icon: "crown.fill",
    baseCost: 150,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Earn 10,000 lifetime points",
    tier: .elite,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 10000,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.goldenDih.rawValue] = level
      return "Golden chance: \(Int(DihEconomy.goldenChance(in: projectedSave) * 100))%"
    }
  )
}
