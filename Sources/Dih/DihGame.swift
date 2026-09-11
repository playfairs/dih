import SwiftUI

@MainActor
final class DihGame: ObservableObject {
    @Published private(set) var score = 0
    @Published private(set) var attempts = 0
    @Published var buttonPosition = CGPoint(x: 220, y: 150)
    @Published var buttonText = "click me"
    @Published var message = "Catch me."

    private let buttonNames = ["catch me", "nope", "again", "try again", "lol", ">:)"]
    private let reactions = [
        "Nice.", "Again.", "You got me.", "Stop clicking me.",
        "Why are you doing this?", "HELP", "That was almost impressive."
    ]

    func caught(in size: CGSize, openClone: () -> Void) {
        score += 1
        attempts += 1

        switch Int.random(in: 0...5) {
        case 0:
            message = "You caught me."
        case 1:
            message = "Too slow."
            buttonText = buttonNames.randomElement() ?? "nope"
        case 2:
            message = "I brought a friend."
            openClone()
        case 3:
            message = "RUN!"
            runAway(from: size)
            return
        default:
            message = reactions.randomElement() ?? "Nice."
        }

        moveButton(in: size)
    }

    func runAway(from size: CGSize) {
        guard attempts > 0 else {
            moveButton(in: size)
            return
        }

        withAnimation(.easeOut(duration: 0.12)) {
            buttonPosition = randomPosition(in: size)
        }
    }

    func reset() {
        score = 0
        attempts = 0
        buttonText = "click me"
        message = "Catch me."
        buttonPosition = CGPoint(x: 220, y: 150)
    }

    private func moveButton(in size: CGSize) {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            buttonPosition = randomPosition(in: size)
        }
    }

    private func randomPosition(in size: CGSize) -> CGPoint {
        let horizontalRange = 80...max(81, size.width - 80)
        let verticalRange = 110...max(111, size.height - 45)
        return CGPoint(
            x: CGFloat.random(in: horizontalRange),
            y: CGFloat.random(in: verticalRange)
        )
    }
}