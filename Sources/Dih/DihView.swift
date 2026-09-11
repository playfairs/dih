import SwiftUI

struct DihView: View {
    var body: some View {
        TabView {
            CatchMeView()
                .tabItem { Label("Catch Me", systemImage: "target") }

            HotlineView()
                .tabItem { Label("Hotline", systemImage: "phone.down.fill") }
        }
        .frame(minWidth: 560, minHeight: 430)
    }
}

struct CatchMeView: View {
    @Environment(\.openWindow) private var openWindow
    @StateObject private var game = DihGame()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("DIH ARCADE")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.orange)
                            Text("Catch the button")
                                .font(.largeTitle.bold())
                            Text("A tiny game with a frankly unreasonable attitude.")
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("SCORE")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text("\(game.score)")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                        }
                    }

                    HStack {
                        Label(game.message, systemImage: "bubble.left.fill")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("attempts: \(game.attempts)")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    Text("The button knows you are coming.")
                        .font(.headline)

                    Spacer()
                }
                .padding(24)

                Button(game.buttonText) {
                    game.caught(in: geometry.size) {
                        openWindow(id: "dih")
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .position(game.buttonPosition)
                .onHover { hovering in
                    if hovering {
                        game.runAway(from: geometry.size)
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Text("Hovering counts as cheating.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Button("Reset", systemImage: "arrow.counterclockwise") {
                            game.reset()
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .padding(18)
            }
        }
    }
}