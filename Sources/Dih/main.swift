import SwiftUI

@main
struct DihApp: App {
    var body: some Scene {
        WindowGroup {
            DihView()
        }

        Window("Dih", id: "dih") {
            DihView()
        }
    }
}

struct DihView: View {
    @Environment(\.openWindow) private var openWindow

    @State private var score = 0
    @State private var buttonPosition = CGPoint(x: 200, y: 150)
    @State private var buttonText = "click me"
    @State private var message = "Catch me."

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    HStack {
                        Text("Score: \(score)")
                            .font(.headline)

                        Spacer()

                        Text(message)
                            .foregroundStyle(.secondary)
                    }
                    .padding()

                    Spacer()
                }

                Button(buttonText) {
                    caught(geometry.size)
                }
                .buttonStyle(.borderedProminent)
                .position(buttonPosition)
                .onHover { hovering in
                    if hovering {
                        runAway(from: geometry.size)
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }

    private func caught(_ size: CGSize) {
        score += 1

        let action = Int.random(in: 0...4)

        switch action {
        case 0:
            message = "You caught me."

            moveButton(in: size)

        case 1:
            message = "Too slow."

            buttonText = [
                "catch me",
                "nope",
                "again",
                "try again",
                "lol",
                ">:)"
            ].randomElement()!

            moveButton(in: size)

        case 2:
            message = "I brought friends."

            openWindow(id: "dih")
            moveButton(in: size)

        case 3:
            message = "RUN!"

            runAway(from: size)

        case 4:
            message = [
                "Nice.",
                "Again.",
                "You got me.",
                "Stop clicking me.",
                "Why are you doing this?",
                "HELP"
            ].randomElement()!

            moveButton(in: size)

        default:
            break
        }
    }

    private func moveButton(in size: CGSize) {
        let x = CGFloat.random(in: 70...(size.width - 70))
        let y = CGFloat.random(in: 100...(size.height - 50))

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            buttonPosition = CGPoint(x: x, y: y)
        }
    }

    private func runAway(from size: CGSize) {
        guard score > 0 else {
            moveButton(in: size)
            return
        }

        let x = CGFloat.random(in: 70...(size.width - 70))
        let y = CGFloat.random(in: 100...(size.height - 50))

        withAnimation(.easeOut(duration: 0.12)) {
            buttonPosition = CGPoint(x: x, y: y)
        }
    }
}