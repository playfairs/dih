import Foundation

public extension DihUpgradeDefinition {
  static let hotlineMultiplier = DihUpgradeDefinition(
    id: .hotlineMultiplier,
    name: "Hotline Multiplier",
    description: "Multiplies helper payouts.",
    icon: "multiply.circle.fill",
    baseCost: 110,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Automated Hotline Lv. 2",
    tier: .elite,
    prerequisites: [(.automatedHotline, 2)],
    minimumCatches: 0,
    minimumPoints: 1000,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.hotlineMultiplier.rawValue] = level
      return "Passive multiplier: \(Int(DihEconomy.passiveMultiplier(in: projectedSave) * 100))%"
    }
  )
}
