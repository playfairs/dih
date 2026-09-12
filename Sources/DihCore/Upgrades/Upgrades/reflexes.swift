import Foundation

public extension DihUpgradeDefinition {
  static let reflexes = DihUpgradeDefinition(
    id: .reflexes,
    name: "Reflexes",
    description: "Makes hover escapes much less likely.",
    icon: "hare.fill",
    baseCost: 45,
    costGrowthRate: 0.02,
    baseEffect: 0.04,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Escape Prediction Lv. 3",
    tier: .expert,
    prerequisites: [(.escapePrediction, 3)],
    minimumCatches: 50,
    minimumPoints: 0,
    effectDescription: { save, level in
      return "Hover escape reduced"
    }
  )
}
