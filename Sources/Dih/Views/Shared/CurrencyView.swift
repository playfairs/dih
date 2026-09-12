import DihCore
import SwiftUI

struct CurrencyView: View {
  @EnvironmentObject private var game: DihGame
  @EnvironmentObject private var settings: DihSettings
  let points: Int

  var body: some View {
    VStack(alignment: .trailing, spacing: 2) {
      Label("POINTS", systemImage: "circle.fill")
        .font(.caption.weight(.bold))
        .foregroundStyle(.secondary)
      HStack(alignment: .lastTextBaseline, spacing: 8) {
        if settings.data.showScorePopups, let scorePopup = game.scorePopup {
          Text(scorePopup)
            .font(.headline.bold().monospacedDigit())
            .foregroundStyle(.orange)
            .id(game.scorePopupID)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
        Text("\(points)")
          .font(.system(size: 34, weight: .black, design: .rounded))
          .contentTransition(.numericText())
      }
      .animation(.easeOut(duration: 0.35), value: game.scorePopupID)
    }
  }
}
