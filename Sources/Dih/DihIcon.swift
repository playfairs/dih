import AppKit

@MainActor
enum DihIcon {
    static func configureRuntimeIcon() {
        guard let url = Bundle.module.url(forResource: "AppIcon", withExtension: "png"),
              let image = NSImage(contentsOf: url) else { return }
        NSApplication.shared.applicationIconImage = image
    }
}
