import Foundation

public extension DihUpgradeDefinition {
  static let quickHands = DihUpgradeDefinition(
    id: .quickHands,
    name: "Quick Hands",
    description: "Adds one point to every catch.",
    icon: "bolt.fill",
    baseCost: 12,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Available immediately",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      return "+\(level) points per catch"
    }
  )
}
