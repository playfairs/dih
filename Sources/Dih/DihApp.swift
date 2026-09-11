import SwiftUI

@main
struct DihApp: App {
    var body: some Scene {
        WindowGroup {
            DihView()
        }
        .windowResizability(.contentSize)

        Window("Another Dih", id: "dih") {
            CatchMeView()
        }
    }
}