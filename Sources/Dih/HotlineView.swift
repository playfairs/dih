import SwiftUI

struct HotlineView: View {
    @State private var answer = "Press the button for advice you absolutely did not request."
    @State private var callCount = 0

    private let answers = [
        "The vibes are confusing, but the snacks are good.",
        "Your future contains a button. It will run away.",
        "Do one small thing, then dramatically announce it.",
        "The universe says: maybe close one browser tab.",
        "You are doing great. Suspiciously great.",
        "A wise person once said: \"ship it and observe.\""
    ]

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "phone.down.fill")
                .font(.system(size: 42))
                .foregroundStyle(.orange)

            Text("DIH HOTLINE")
                .font(.caption.weight(.bold))
                .foregroundStyle(.orange)
            Text("Unqualified advice, instantly.")
                .font(.title.bold())
            Text(answer)
                .font(.title3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)
                .foregroundStyle(.secondary)

            Button("Call the hotline", systemImage: "phone.fill") {
                answer = answers.randomElement() ?? answer
                callCount += 1
            }
            .buttonStyle(.borderedProminent)

            Text("calls made: \(callCount)")
                .font(.caption.monospaced())
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }
}