import SwiftUI
import DihCore

@main
struct DihApp: App {
    @StateObject private var game = DihGame()

    var body: some Scene {
        WindowGroup {
            DihView()
                .environmentObject(game)
        }
        .windowResizability(.contentSize)

        Window("Another Dih", id: "dih") {
            CatchMeView()
                .environmentObject(game)
        }
    }
}