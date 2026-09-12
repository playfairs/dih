import DihCore
import SwiftUI

struct ArenaView: View {
  @Environment(\.openWindow) private var openWindow
  @EnvironmentObject private var game: DihGame
  @EnvironmentObject private var settings: DihSettings

  var body: some View {
    GeometryReader { proxy in
      let arena = CGRect(origin: .zero, size: proxy.size)
      let buttonSize = CGSize(
        width: max(112, CGFloat(game.buttonText.count) * 8 + 44) * game.effectiveTargetScale,
        height: 42 * game.effectiveTargetScale)
      let desiredPosition =
        settings.data.reducedMovement ? CGPoint(x: arena.midX, y: arena.midY) : game.buttonPosition
      let displayedPosition = DihArena.clampedCenter(
        in: arena, buttonSize: buttonSize, desired: desiredPosition)

      ZStack {
        RoundedRectangle(cornerRadius: 14)
          .fill(settings.data.highContrast ? Color.black : Color.primary.opacity(0.035))
          .overlay(
            RoundedRectangle(cornerRadius: 14).stroke(
              settings.data.highContrast ? Color.white : Color.primary.opacity(0.12)))

        Button(game.buttonText) {
          withAnimation(movementAnimation) {
            let openedClone = game.caught(in: arena, buttonSize: buttonSize)
            DihSoundEffects.play(.catchButton, settings: settings)
            if openedClone { openWindow(id: "dih") }
          }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(width: buttonSize.width, height: buttonSize.height)
        .position(displayedPosition)
        .onHover { hovering in
          if hovering {
            withAnimation(movementAnimation) { game.runAway(from: arena, buttonSize: buttonSize) }
          }
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .task(
        id:
          "\(proxy.size.width),\(proxy.size.height),\(game.buttonText),\(game.effectiveTargetScale)"
      ) {
        while !Task.isCancelled {
          try? await Task.sleep(for: .milliseconds(500))
          guard !Task.isCancelled else { return }
          withAnimation(movementAnimation) {
            game.autonomousMoveIfNeeded(in: arena, buttonSize: buttonSize)
          }
        }
      }
    }
  }

  private var movementAnimation: Animation? {
    guard !settings.data.reducedMovement else { return nil }
    return .easeOut(duration: max(0.08, 0.22 * settings.data.animationIntensity))
  }
}
