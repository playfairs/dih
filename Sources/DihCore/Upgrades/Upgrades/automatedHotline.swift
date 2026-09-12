import Foundation

public extension DihUpgradeDefinition {
  static let automatedHotline = DihUpgradeDefinition(
    id: .automatedHotline,
    name: "Automated Hotline",
    description: "Greatly improves passive generation.",
    icon: "gearshape.2.fill",
    baseCost: 80,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: 10,
    unlockText: "Requires Dedicated Operator Lv. 2",
    tier: .elite,
    prerequisites: [(.dedicatedOperator, 2)],
    minimumCatches: 0,
    minimumPoints: 500,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.automatedHotline.rawValue] = level
      return "Passive multiplier: \(Int(DihEconomy.passiveMultiplier(in: projectedSave) * 100))%"
    }
  )
}
