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

  public init(
    id: DihUpgradeID, name: String, description: String, icon: String, baseCost: Int,
    costGrowthRate: Double = 0.02, baseEffect: Double = 1.0,
    effectGrowthRate: Double = 0.05,
    maximumLevel: Int = DihUpgradeConstants.defaultMaximumLevel, unlockText: String,
    tier: DihUpgradeTier = .basic, prerequisites: [(DihUpgradeID, Int)] = [],
    minimumCatches: Int = 0, minimumPoints: Int = 0
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
  }

  public static let all: [DihUpgradeDefinition] = [
    .init(
      id: .betterGrip, name: "Better Grip", description: "The button hesitates before escaping.",
      icon: "hand.raised.fill", baseCost: 8, costGrowthRate: 0.02, baseEffect: 0.05,
      effectGrowthRate: 0.05, unlockText: "Available immediately"),
    .init(
      id: .biggerTarget, name: "Bigger Target", description: "Makes the target more forgiving.",
      icon: "arrow.up.left.and.arrow.down.right", baseCost: 10, costGrowthRate: 0.02,
      baseEffect: 1.0, effectGrowthRate: 0.05,
      maximumLevel: DihUpgradeConstants.biggerTargetMaximumLevel,
      unlockText: "Available immediately"),
    .init(
      id: .quickHands, name: "Quick Hands", description: "Adds one point to every catch.",
      icon: "bolt.fill", baseCost: 12, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Available immediately"),
    .init(
      id: .magnetHands, name: "Magnet Hands", description: "Expands the effective clickable area.",
      icon: "scope", baseCost: 18, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Requires Bigger Target Lv. 2",
      prerequisites: [(.biggerTarget, 2)]),
    .init(
      id: .stickyButton, name: "Sticky Button",
      description: "Reduces movement frequency after a catch.", icon: "pin.fill", baseCost: 24,
      costGrowthRate: 0.02, baseEffect: 0.12, effectGrowthRate: 0.05,
      unlockText: "Requires Better Grip Lv. 2", tier: .advanced,
      prerequisites: [(.betterGrip, 2)], minimumCatches: 10),
    .init(
      id: .slowerDih, name: "Slower Dih", description: "Makes escapes less frantic.",
      icon: "tortoise.fill", baseCost: 28, costGrowthRate: 0.02, baseEffect: 0.03,
      effectGrowthRate: 0.05, unlockText: "Requires Sticky Button Lv. 2", tier: .advanced,
      prerequisites: [(.stickyButton, 2)], minimumCatches: 25),
    .init(
      id: .escapePrediction, name: "Escape Prediction", description: "Reduces surprise escapes.",
      icon: "eye.fill", baseCost: 16, costGrowthRate: 0.02, baseEffect: 0.05,
      effectGrowthRate: 0.05, unlockText: "Catch 15 buttons", minimumCatches: 15),
    .init(
      id: .reflexes, name: "Reflexes", description: "Makes hover escapes much less likely.",
      icon: "hare.fill", baseCost: 45, costGrowthRate: 0.02, baseEffect: 0.04,
      effectGrowthRate: 0.05, unlockText: "Requires Escape Prediction Lv. 3", tier: .expert,
      prerequisites: [(.escapePrediction, 3)], minimumCatches: 50),
    .init(
      id: .comboTraining, name: "Combo Training", description: "Improves streak rewards.",
      icon: "figure.run", baseCost: 32, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Catch 10 buttons", minimumCatches: 10),
    .init(
      id: .combo, name: "Combo", description: "Long streaks add extra points.", icon: "flame.fill",
      baseCost: 25, costGrowthRate: 0.02, baseEffect: 1.0, effectGrowthRate: 0.05,
      unlockText: "Requires Combo Training Lv. 2", tier: .advanced,
      prerequisites: [(.comboTraining, 2)], minimumCatches: 20),
    .init(
      id: .hotlineEfficiency, name: "Hotline Efficiency",
      description: "Your helper earns more per payout.", icon: "phone.badge.waveform.fill",
      baseCost: 15, costGrowthRate: 0.02, baseEffect: 1.0, effectGrowthRate: 0.0,
      unlockText: "Call the hotline once"),
    .init(
      id: .fasterHotline, name: "Faster Hotline", description: "Shortens the helper wait.",
      icon: "gauge.with.dots.needle.67percent", baseCost: 20, costGrowthRate: 0.02,
      baseEffect: 1.0, effectGrowthRate: 0.05, unlockText: "Call the hotline once"),
    .init(
      id: .betterAdvice, name: "Better Advice", description: "Advice earns a small passive bonus.",
      icon: "lightbulb.fill", baseCost: 35, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Requires Hotline Efficiency Lv. 2", tier: .advanced,
      prerequisites: [(.hotlineEfficiency, 2)]),
    .init(
      id: .dedicatedOperator, name: "Dedicated Operator",
      description: "Raises the offline earnings cap.", icon: "person.crop.circle.badge.checkmark",
      baseCost: 50, costGrowthRate: 0.02, baseEffect: 1.0, effectGrowthRate: 0.05,
      unlockText: "Requires Faster Hotline Lv. 3", tier: .expert,
      prerequisites: [(.fasterHotline, 3)], minimumPoints: 100),
    .init(
      id: .automatedHotline, name: "Automated Hotline",
      description: "Greatly improves passive generation.", icon: "gearshape.2.fill", baseCost: 80,
      costGrowthRate: 0.02, baseEffect: 1.0, effectGrowthRate: 0.05,
      unlockText: "Requires Dedicated Operator Lv. 2", tier: .elite,
      prerequisites: [(.dedicatedOperator, 2)], minimumPoints: 500),
    .init(
      id: .hotlineMultiplier, name: "Hotline Multiplier", description: "Multiplies helper payouts.",
      icon: "multiply.circle.fill", baseCost: 110, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Requires Automated Hotline Lv. 2", tier: .elite,
      prerequisites: [(.automatedHotline, 2)], minimumPoints: 1_000),
    .init(
      id: .cloneDiscount, name: "Clone Discount", description: "Clones appear more often.",
      icon: "square.on.square", baseCost: 10, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Open a clone window"),
    .init(
      id: .cloneCapacity, name: "Clone Capacity", description: "Allows more clone windows.",
      icon: "rectangle.stack.badge.plus", baseCost: 30, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Requires Clone Discount Lv. 2", tier: .advanced,
      prerequisites: [(.cloneDiscount, 2)]),
    .init(
      id: .cloneRewards, name: "Clone Rewards", description: "Clone catches pay more.",
      icon: "gift.fill", baseCost: 40, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Catch in a clone window", tier: .advanced,
      minimumCatches: 30),
    .init(
      id: .cloneCoordination, name: "Clone Coordination",
      description: "Clone buttons become easier.", icon: "person.2.fill", baseCost: 55,
      costGrowthRate: 0.02, baseEffect: 1.0, effectGrowthRate: 0.05,
      unlockText: "Requires Clone Rewards Lv. 2", tier: .expert,
      prerequisites: [(.cloneRewards, 2)]),
    .init(
      id: .cloneMultiplier, name: "Clone Multiplier", description: "Multiplies clone rewards.",
      icon: "square.3.layers.3d", baseCost: 100, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Requires Clone Coordination Lv. 2", tier: .elite,
      prerequisites: [(.cloneCoordination, 2)], minimumPoints: 1_000),
    .init(
      id: .luckyDih, name: "Lucky Dih", description: "Adds a chance for bonus points.",
      icon: "sparkles", baseCost: 18, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Catch 20 buttons", minimumCatches: 20),
    .init(
      id: .criticalCatch, name: "Critical Catch", description: "Rare catches pay a large bonus.",
      icon: "burst.fill", baseCost: 60, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Requires Lucky Dih Lv. 3", tier: .expert,
      prerequisites: [(.luckyDih, 3)], minimumPoints: 250),
    .init(
      id: .pointMultiplier, name: "Point Multiplier",
      description: "Increases all active catch rewards.", icon: "xmark.circle.fill", baseCost: 75,
      costGrowthRate: 0.02, baseEffect: 1.0, effectGrowthRate: 0.05,
      unlockText: "Earn 1,000 lifetime points", tier: .expert, minimumPoints: 1_000),
    .init(
      id: .streakMastery, name: "Streak Mastery", description: "Makes streaks more valuable.",
      icon: "chart.line.uptrend.xyaxis", baseCost: 90, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Reach a 25 catch streak", tier: .expert,
      minimumCatches: 25),
    .init(
      id: .goldenDih, name: "Golden Dih", description: "Unlocks rare golden catches.",
      icon: "crown.fill", baseCost: 150, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Earn 10,000 lifetime points", tier: .elite,
      minimumPoints: 10_000),
    .init(
      id: .secondChance, name: "Second Chance", description: "Sometimes protects your streak.",
      icon: "arrow.uturn.backward.circle.fill", baseCost: 70, costGrowthRate: 0.02,
      baseEffect: 1.0, effectGrowthRate: 0.05, unlockText: "Reach a 25 catch streak",
      tier: .expert, minimumCatches: 25),
    .init(
      id: .arcadeLuck, name: "Arcade Luck", description: "Improves rare event odds.",
      icon: "dice.fill", baseCost: 125, costGrowthRate: 0.02, baseEffect: 1.0,
      effectGrowthRate: 0.05, unlockText: "Earn 5,000 lifetime points", tier: .elite,
      minimumPoints: 5_000),
  ]

  public static func definition(for id: DihUpgradeID) -> DihUpgradeDefinition {
    all.first { $0.id == id } ?? all[0]
  }
}
