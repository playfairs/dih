import Foundation

public enum DihAchievementSystem {
  public static func newlyCompleted(in save: DihSaveData, totalUpgrades: Int) -> [DihAchievementID]
  {
    let checks: [(DihAchievementID, Bool)] = [
      (.firstCatch, save.totalCatches >= 1), (.catches10, save.totalCatches >= 10),
      (.catches100, save.totalCatches >= 100), (.catches1000, save.totalCatches >= 1000),
      (.firstUpgrade, totalUpgrades >= 1), (.firstHotlineCall, save.totalHotlineCalls >= 1),
      (.firstPassivePoint, save.passivePointsGenerated >= 1),
      (.passive100, save.passivePointsGenerated >= 100),
      (.points10000, save.totalPointsEarned >= 10_000), (.streak10, save.bestStreak >= 10),
      (.streak50, save.bestStreak >= 50), (.clone10, save.totalCloneWindowsOpened >= 10),
      (.firstOffline, save.totalOfflinePoints > 0), (.upgradeCollector, totalUpgrades >= 10),
      (.goldenCatch, save.goldenCatches > 0), (.criticalCatch, save.criticalCatches > 0),
      (.millionaire, save.points >= 1_000_000),
      (.upgradeEverything, totalUpgrades >= DihUpgradeID.allCases.count),
    ]
    let unlocked = Set(save.achievements)
    return checks.compactMap { achievement, complete in
      complete && !unlocked.contains(achievement.rawValue) ? achievement : nil
    }
  }
}
