import DihCore
import SwiftUI

struct DihView: View {
  @EnvironmentObject private var game: DihGame

  var body: some View {
    TabView {
      CatchMeView().tabItem { Label("Play", systemImage: "target") }
      StoreView().tabItem { Label("Store", systemImage: "cart.fill") }
      HotlineView().tabItem { Label("Hotline", systemImage: "phone.down.fill") }
      StatsView().tabItem { Label("Stats", systemImage: "chart.bar.fill") }
      SettingsView().tabItem { Label("Settings", systemImage: "gearshape.fill") }
    }
    .frame(minWidth: 700, minHeight: 540)
    .overlay(alignment: .top) {
      if let toast = game.toast {
        Text(toast)
          .font(.callout.weight(.semibold))
          .padding(.horizontal, 14)
          .padding(.vertical, 9)
          .background(.orange, in: Capsule())
          .foregroundStyle(.white)
          .shadow(radius: 8, y: 3)
          .transition(.move(edge: .top).combined(with: .opacity))
          .onTapGesture { game.clearToast() }
      }
    }
    .animation(.spring(response: 0.3), value: game.toast)
  }
}

struct CatchMeView: View {
  @EnvironmentObject private var game: DihGame

  var body: some View {
    ZStack {
      Color(nsColor: .windowBackgroundColor).ignoresSafeArea()

      VStack(alignment: .leading, spacing: 14) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 3) {
            Text("DIH ARCADE").font(.caption.weight(.black)).foregroundStyle(.orange)
            Text("Catch the button").font(.largeTitle.bold())
            Text("A tiny game with a frankly unreasonable attitude.").foregroundStyle(.secondary)
          }
          Spacer()
          CurrencyView(points: game.points)
        }

        HStack(spacing: 18) {
          MiniStat(title: "STREAK", value: "\(game.currentStreak)", icon: "flame.fill")
          MiniStat(title: "BEST", value: "\(game.bestStreak)", icon: "trophy.fill")
          MiniStat(title: "CATCHES", value: "\(game.totalCatches)", icon: "target")
          Spacer()
        }

        HStack {
          Label(game.message, systemImage: "bubble.left.fill").foregroundStyle(.secondary)
          Spacer()
          Text("accuracy \(game.accuracy, format: .percent.precision(.fractionLength(0)))")
            .font(.caption.monospaced()).foregroundStyle(.secondary)
        }

        Divider()
        Text("The button knows you are coming.").font(.headline)
        ArenaView()
          .frame(minHeight: 250)

        if let summary = game.offlineSummary {
          Text(summary)
            .font(.caption)
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        }

        HStack {
          Text("Hovering counts as cheating.").font(.caption).foregroundStyle(.tertiary)
          Spacer()
          Text("points per catch: \(DihEconomy.pointsPerCatch(in: game.save))")
            .font(.caption.monospaced()).foregroundStyle(.tertiary)
        }
      }
      .padding(24)
    }
  }
}
