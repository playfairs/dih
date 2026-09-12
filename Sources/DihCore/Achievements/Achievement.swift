import Foundation

public enum DihAchievementID: String, CaseIterable, Codable, Sendable {
  case firstCatch, catches10, catches100, catches1000
  case firstUpgrade, firstHotlineCall, firstPassivePoint, passive100
  case points10000, streak10, streak50, clone10, firstOffline, upgradeCollector
  case goldenCatch, criticalCatch, millionaire, upgradeEverything

  public var title: String {
    switch self {
    case .firstCatch: "First Contact"
    case .catches10: "Getting the Hang of It"
    case .catches100: "Professional Button Catcher"
    case .catches1000: "Please Go Outside"
    case .firstUpgrade: "Retail Therapy"
    case .firstHotlineCall: "On Hold"
    case .firstPassivePoint: "Money While Sleeping"
    case .passive100: "The Hotline Works"
    case .points10000: "Pointy Situation"
    case .streak10: "Unreasonably Consistent"
    case .streak50: "The Button Is Sweating"
    case .clone10: "It Has Friends Now"
    case .firstOffline: "Welcome Back"
    case .upgradeCollector: "Upgrade Collector"
    case .goldenCatch: "Golden Catch"
    case .criticalCatch: "Critical Condition"
    case .millionaire: "Millionaire"
    case .upgradeEverything: "Everything Is Fine"
    }
  }

  public var icon: String {
    switch self {
    case .firstCatch, .catches10, .catches100, .catches1000: "target"
    case .firstUpgrade: "cart.fill"
    case .firstHotlineCall, .passive100, .firstPassivePoint: "phone.fill"
    case .points10000: "star.fill"
    case .streak10, .streak50: "flame.fill"
    case .clone10: "square.on.square"
    case .firstOffline: "moon.stars.fill"
    case .upgradeCollector: "shippingbox.fill"
    case .goldenCatch: "crown.fill"
    case .criticalCatch: "burst.fill"
    case .millionaire: "banknote.fill"
    case .upgradeEverything: "checkmark.seal.fill"
    }
  }
}
