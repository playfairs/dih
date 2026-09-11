import AppKit
import SwiftUI
import DihCore

@main
struct DihApp: App {
    @NSApplicationDelegateAdaptor(DihApplicationDelegate.self) private var applicationDelegate
    @StateObject private var settings: DihSettings
    @StateObject private var game: DihGame

    init() {
        let settings = DihSettings()
        _settings = StateObject(wrappedValue: settings)
        _game = StateObject(wrappedValue: DihGame(settings: settings))
    }

    var body: some Scene {
        WindowGroup {
            DihView()
                .environmentObject(game)
                .environmentObject(settings)
        }
        .defaultSize(width: 760, height: 600)

        Window("Another Dih", id: "dih") {
            CatchMeView()
                .environmentObject(game)
                .environmentObject(settings)
        }
            .defaultSize(width: 620, height: 460)
    }
}

@MainActor
final class DihApplicationDelegate: NSObject, NSApplicationDelegate {
    private var initialWindowFocused = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        focusInitialWindowWhenAvailable()
    }

    private func focusInitialWindowWhenAvailable() {
        guard !initialWindowFocused else { return }

        guard let window = NSApp.windows.first(where: { $0.isVisible }) else {
            DispatchQueue.main.async { [weak self] in
                self?.focusInitialWindowWhenAvailable()
            }
            return
        }

        initialWindowFocused = true
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}