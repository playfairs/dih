import Foundation

public extension DihUpgradeDefinition {
  static let cloneCoordination = DihUpgradeDefinition(
    id: .cloneCoordination,
    name: "Clone Coordination",
    description: "Clone buttons become easier.",
    icon: "person.2.fill",
    baseCost: 55,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Clone Rewards Lv. 2",
    tier: .expert,
    prerequisites: [(.cloneRewards, 2)],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.cloneCoordination.rawValue] = level
      return "Clone target: \(Int(DihEconomy.cloneTargetMultiplier(in: projectedSave) * 100))%"
    }
  )
}
