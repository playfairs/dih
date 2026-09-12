import Foundation

public extension DihUpgradeDefinition {
  static let escapePrediction = DihUpgradeDefinition(
    id: .escapePrediction,
    name: "Escape Prediction",
    description: "Reduces surprise escapes.",
    icon: "eye.fill",
    baseCost: 16,
    costGrowthRate: 0.02,
    baseEffect: 0.05,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Catch 15 buttons",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 15,
    minimumPoints: 0,
    effectDescription: { save, level in
      return "Fewer surprise escapes"
    }
  )
}
