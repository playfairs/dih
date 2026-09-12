import Foundation

public extension DihUpgradeDefinition {
  static let betterGrip = DihUpgradeDefinition(
    id: .betterGrip,
    name: "Better Grip",
    description: "The button hesitates before escaping.",
    icon: "hand.raised.fill",
    baseCost: 8,
    costGrowthRate: 0.02,
    baseEffect: 0.05,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Available immediately",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.betterGrip.rawValue] = level
      return "Escape chance: \(Int(DihEconomy.runAwayChance(in: projectedSave) * 100))%"
    }
  )
}
