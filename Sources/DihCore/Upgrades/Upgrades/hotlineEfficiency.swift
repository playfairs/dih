import Foundation

public extension DihUpgradeDefinition {
  static let hotlineEfficiency = DihUpgradeDefinition(
    id: .hotlineEfficiency,
    name: "Hotline Efficiency",
    description: "Your helper earns more per payout.",
    icon: "phone.badge.waveform.fill",
    baseCost: 15,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.0,
    maximumLevel: DihUpgradeConstants.defaultMaximumLevel,
    unlockText: "Call the hotline once",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.hotlineEfficiency.rawValue] = level
      return "Payout: \(DihEconomy.passivePointsPerInterval(in: projectedSave)) points"
    }
  )
}
