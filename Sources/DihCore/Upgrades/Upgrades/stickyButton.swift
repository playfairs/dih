import Foundation

public extension DihUpgradeDefinition {
  static let stickyButton = DihUpgradeDefinition(
    id: .stickyButton,
    name: "Sticky Button",
    description: "Reduces movement frequency after a catch.",
    icon: "pin.fill",
    baseCost: 24,
    costGrowthRate: 0.02,
    baseEffect: 0.12,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Better Grip Lv. 2",
    tier: .advanced,
    prerequisites: [(.betterGrip, 2)],
    minimumCatches: 10,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.stickyButton.rawValue] = level
      return "Movement delay: \(Int(DihEconomy.movementDelay(in: projectedSave)))s"
    }
  )
}
