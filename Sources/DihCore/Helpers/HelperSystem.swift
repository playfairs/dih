import Foundation

public struct DihHelperSystem {
  public static let firstHelperCost = 100
  public static let helperCostGrowth = 1.10
  public static let basePointsPerHelper = 1.0
  public static let baseInterval = 14.0

  public static func owned(in save: DihSaveData) -> Int { save.ownedHelpers }

  public static func level(in save: DihSaveData) -> Int {
    DihEconomy.level(for: .hotlineEfficiency, in: save)
  }

  public static func cost(forOwned owned: Int) -> Int {
    DihEconomy.helperCost(forOwned: owned)
  }

  public static func pointsPerHelper(in save: DihSaveData) -> Double {
    DihEconomy.helperIncomePerHelper(in: save)
  }

  public static func totalPassiveIncome(in save: DihSaveData) -> Double {
    DihEconomy.totalPassiveIncome(in: save)
  }

  public static func payout(in save: DihSaveData) -> Int {
    Int(ceil(totalPassiveIncome(in: save)))
  }

  public static func interval(in save: DihSaveData) -> TimeInterval {
    DihEconomy.passiveInterval(in: save)
  }

  public static func rate(in save: DihSaveData) -> Double {
    let interval = interval(in: save)
    guard interval > 0 else { return 0 }
    return Double(payout(in: save)) / interval
  }

  public static func lifetime(in save: DihSaveData) -> Int {
    save.passivePointsGenerated
  }

  public static func offlineDuration(in save: DihSaveData) -> TimeInterval {
    DihEconomy.offlineDuration(in: save)
  }

  public static func purchase(_ save: inout DihSaveData) -> Bool {
    let cost = cost(forOwned: save.ownedHelpers)
    guard save.points >= cost else { return false }
    save.points -= cost
    save.ownedHelpers += 1
    save.totalHotlineCalls += 1
    return true
  }
}
