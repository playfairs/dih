import Foundation

public extension DihUpgradeDefinition {
  static let betterAdvice = DihUpgradeDefinition(
    id: .betterAdvice,
    name: "Better Advice",
    description: "Advice earns a small passive bonus.",
    icon: "lightbulb.fill",
    baseCost: 35,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Hotline Efficiency Lv. 2",
    tier: .advanced,
    prerequisites: [(.hotlineEfficiency, 2)],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.betterAdvice.rawValue] = level
      return "Advice efficiency: \(Int(DihEconomy.passiveMultiplier(in: projectedSave) * 100))%"
    }
  )
}
