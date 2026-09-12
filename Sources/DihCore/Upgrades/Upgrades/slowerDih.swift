import Foundation

public extension DihUpgradeDefinition {
  static let slowerDih = DihUpgradeDefinition(
    id: .slowerDih,
    name: "Slower Dih",
    description: "Makes escapes less frantic.",
    icon: "tortoise.fill",
    baseCost: 28,
    costGrowthRate: 0.02,
    baseEffect: 0.03,
    effectGrowthRate: 0.05,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Requires Sticky Button Lv. 2",
    tier: .advanced,
    prerequisites: [(.stickyButton, 2)],
    minimumCatches: 25,
    minimumPoints: 0,
    effectDescription: { save, level in
      return "Escape and self-move chance reduced"
    }
  )
}
