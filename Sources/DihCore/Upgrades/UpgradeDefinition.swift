import Foundation

public enum DihUpgradeConstants {
  public static let defaultMaximumLevel = 9999
  public static let biggerTargetMaximumLevel = 10
}

public enum DihUpgradeID: String, CaseIterable, Codable, Identifiable, Sendable {
  case betterGrip, stickyButton, slowerDih, magnetHands, reflexes, quickHands, comboTraining
  case hotlineEfficiency, fasterHotline, betterAdvice, dedicatedOperator, automatedHotline,
    hotlineMultiplier
  case cloneDiscount, cloneCapacity, cloneRewards, cloneCoordination, cloneMultiplier
  case luckyDih, criticalCatch, pointMultiplier, streakMastery, goldenDih, secondChance, arcadeLuck
  case escapePrediction, biggerTarget, combo
  public var id: String { rawValue }
}

public enum DihUpgradeTier: String, Codable, CaseIterable, Sendable {
  case basic = "Basic"
  case advanced = "Advanced"
  case expert = "Expert"
  case elite = "Elite"
}

public struct DihUpgradeDefinition: Identifiable, Sendable {
  public let id: DihUpgradeID
  public let name: String
  public let description: String
  public let icon: String
  public let baseCost: Int
  public let costGrowthRate: Double
  public let baseEffect: Double
  public let effectGrowthRate: Double
  public let maximumLevel: Int
  public let unlockText: String
  public let tier: DihUpgradeTier
  public let prerequisites: [(DihUpgradeID, Int)]
  public let minimumCatches: Int
  public let minimumPoints: Int
  public let effectDescription: @Sendable (DihSaveData, Int) -> String

  public init(
    id: DihUpgradeID, name: String, description: String, icon: String, baseCost: Int,
    costGrowthRate: Double = 0.02, baseEffect: Double = 1.0,
    effectGrowthRate: Double = 0.05,
    maximumLevel: Int = DihUpgradeConstants.defaultMaximumLevel, unlockText: String,
    tier: DihUpgradeTier = .basic, prerequisites: [(DihUpgradeID, Int)] = [],
    minimumCatches: Int = 0, minimumPoints: Int = 0,
    effectDescription: @Sendable @escaping (DihSaveData, Int) -> String = { _, _ in "" }
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.icon = icon
    self.baseCost = baseCost
    self.costGrowthRate = costGrowthRate
    self.baseEffect = baseEffect
    self.effectGrowthRate = effectGrowthRate
    self.maximumLevel = maximumLevel
    self.unlockText = unlockText
    self.tier = tier
    self.prerequisites = prerequisites
    self.minimumCatches = minimumCatches
    self.minimumPoints = minimumPoints
    self.effectDescription = effectDescription
  }

  public static let all: [DihUpgradeDefinition] = [
    DihUpgradeDefinition.betterGrip,
    DihUpgradeDefinition.biggerTarget,
    DihUpgradeDefinition.quickHands,
    DihUpgradeDefinition.magnetHands,
    DihUpgradeDefinition.stickyButton,
    DihUpgradeDefinition.slowerDih,
    DihUpgradeDefinition.escapePrediction,
    DihUpgradeDefinition.reflexes,
    DihUpgradeDefinition.comboTraining,
    DihUpgradeDefinition.combo,
    DihUpgradeDefinition.hotlineEfficiency,
    DihUpgradeDefinition.fasterHotline,
    DihUpgradeDefinition.betterAdvice,
    DihUpgradeDefinition.dedicatedOperator,
    DihUpgradeDefinition.automatedHotline,
    DihUpgradeDefinition.hotlineMultiplier,
    DihUpgradeDefinition.cloneDiscount,
    DihUpgradeDefinition.cloneCapacity,
    DihUpgradeDefinition.cloneRewards,
    DihUpgradeDefinition.cloneCoordination,
    DihUpgradeDefinition.cloneMultiplier,
    DihUpgradeDefinition.luckyDih,
    DihUpgradeDefinition.criticalCatch,
    DihUpgradeDefinition.pointMultiplier,
    DihUpgradeDefinition.streakMastery,
    DihUpgradeDefinition.goldenDih,
    DihUpgradeDefinition.secondChance,
    DihUpgradeDefinition.arcadeLuck,
  ]

  public static func definition(for id: DihUpgradeID) -> DihUpgradeDefinition {
    all.first { $0.id == id } ?? all[0]
  }
}
