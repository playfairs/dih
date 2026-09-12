import DihCore
import SwiftUI

struct StatsView: View {
  @EnvironmentObject private var game: DihGame
  @State private var showingResetConfirmation = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 18) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text("DIH STATS").font(.caption.weight(.black)).foregroundStyle(.orange)
            Text("A surprisingly detailed record").font(.title.bold())
          }
          Spacer()
          Button("Reset", systemImage: "trash") { showingResetConfirmation = true }
            .buttonStyle(.borderless).foregroundStyle(.red)
        }

        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
          StatCard(title: "Current points", value: "\(game.points)", icon: "circle.fill")
          StatCard(
            title: "Total earned", value: "\(game.save.totalPointsEarned)",
            icon: "chart.line.uptrend.xyaxis")
          StatCard(title: "Catches", value: "\(game.totalCatches)", icon: "target")
          StatCard(title: "Attempts", value: "\(game.totalAttempts)", icon: "hand.tap.fill")
          StatCard(title: "Best score", value: "\(game.bestScore)", icon: "trophy.fill")
          StatCard(title: "Best streak", value: "\(game.bestStreak)", icon: "flame.fill")
          StatCard(
            title: "Accuracy",
            value: game.accuracy.formatted(.percent.precision(.fractionLength(1))), icon: "scope")
          StatCard(
            title: "Points / minute",
            value: game.averagePointsPerMinute.formatted(.number.precision(.fractionLength(1))),
            icon: "speedometer")
          StatCard(
            title: "Time played", value: formatTime(game.save.totalTimePlayed), icon: "clock.fill")
          StatCard(
            title: "Passive points", value: "\(game.save.passivePointsGenerated)",
            icon: "phone.fill")
          StatCard(
            title: "Offline points", value: "\(game.save.totalOfflinePoints)",
            icon: "moon.stars.fill")
          StatCard(
            title: "Hotline payouts", value: "\(game.save.totalHotlinePayouts)",
            icon: "arrow.down.circle.fill")
          StatCard(title: "Rare catches", value: "\(game.save.rareCatches)", icon: "sparkles")
          StatCard(
            title: "Critical catches", value: "\(game.save.criticalCatches)", icon: "burst.fill")
          StatCard(title: "Golden catches", value: "\(game.save.goldenCatches)", icon: "crown.fill")
          StatCard(
            title: "Longest session", value: formatTime(game.save.longestSession), icon: "hourglass"
          )
          StatCard(
            title: "Resets", value: "\(game.save.resetCount)", icon: "arrow.counterclockwise")
          StatCard(title: "Upgrades", value: "\(game.totalUpgrades)", icon: "arrow.up.circle.fill")
          StatCard(
            title: "Clone windows", value: "\(game.save.totalCloneWindowsOpened)",
            icon: "square.on.square")
        }

        VStack(alignment: .leading, spacing: 10) {
          Text("Achievements").font(.headline)
          LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 8)], spacing: 8) {
            ForEach(DihAchievementID.allCases, id: \.self) { achievement in
              let unlocked = game.unlockedAchievements.contains(achievement)
              Label(achievement.title, systemImage: unlocked ? achievement.icon : "lock.fill")
                .font(.caption)
                .foregroundStyle(unlocked ? .primary : .secondary)
                .padding(9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                  unlocked ? Color.orange.opacity(0.12) : Color.secondary.opacity(0.12),
                  in: RoundedRectangle(cornerRadius: 7))
            }
          }
        }
      }
      .padding(28)
    }
    .alert("Reset all progress?", isPresented: $showingResetConfirmation) {
      Button("Reset Progress", role: .destructive) { game.resetProgress() }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This deletes points, upgrades, achievements, and statistics. It cannot be undone.")
    }
  }

  private func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time / 60)
    if minutes >= 60 { return "\(minutes / 60)h \(minutes % 60)m" }
    return "\(minutes)m"
  }
}
