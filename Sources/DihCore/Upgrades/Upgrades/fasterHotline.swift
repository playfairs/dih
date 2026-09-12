import Foundation

public extension DihUpgradeDefinition {
  static let fasterHotline = DihUpgradeDefinition(
    id: .fasterHotline,
    name: "Faster Hotline",
    description: "Shortens the helper wait.",
    icon: "gauge.with.dots.needle.67percent",
    baseCost: 20,
    costGrowthRate: 0.02,
    baseEffect: 1.0,
    effectGrowthRate: 0.05,
    maximumLevel: 15,
    unlockText: "Call the hotline once",
    tier: .basic,
    prerequisites: [],
    minimumCatches: 0,
    minimumPoints: 0,
    effectDescription: { save, level in
      var projectedSave = save
      projectedSave.upgrades[DihUpgradeID.fasterHotline.rawValue] = level
      return "Payout every \(Int(DihEconomy.passiveInterval(in: projectedSave)))s"
    }
  )
}
