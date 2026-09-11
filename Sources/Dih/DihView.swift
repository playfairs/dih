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
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var game: DihGame

    var body: some View {
        GeometryReader { geometry in
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
                    Spacer()
                }
                .padding(24)

                Button(game.buttonText) {
                    if game.caught(in: geometry.size) { openWindow(id: "dih") }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .scaleEffect(game.targetScale)
                .position(game.buttonPosition)
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: game.buttonPosition)
                .onHover { hovering in
                    if hovering { game.runAway(from: geometry.size) }
                }

                VStack {
                    if let summary = game.offlineSummary {
                        Text(summary)
                            .font(.caption)
                            .padding(10)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                            .frame(maxWidth: 430)
                    }
                    Spacer()
                    HStack {
                        Text("Hovering counts as cheating.").font(.caption).foregroundStyle(.tertiary)
                        Spacer()
                        Text("points per catch: \(DihEconomy.pointsPerCatch(in: game.save))")
                            .font(.caption.monospaced()).foregroundStyle(.tertiary)
                    }
                }
                .padding(18)
            }
        }
    }
}