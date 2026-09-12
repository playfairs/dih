# Dih

Dih is a tiny macOS arcade idle game about catching a button that has made poor
life choices.

## Features

- Bounded evasive-button playfield that adapts to window resizing and upgrades.
- Persistent points, streaks, passive income, offline earnings, upgrades, stats,
  achievements, and clone-window progress.
- Tiered Store with catching, Hotline, clone, and progression upgrades.
- Hotline helper with passive and offline income.
- Separate persistent gameplay/accessibility settings.
- Shared state across clone windows with native macOS focus handling.

## Development

```sh
swift build
swift test
```

The source tree is organized by responsibility: SwiftUI feature views live
under `Sources/Dih/Views`, app/audio/resources are isolated from the UI, and
core gameplay, economy, upgrades, helpers, achievements, settings, and TOML
persistence live under their respective `Sources/DihCore` subsystems.

Progress is stored as a versioned, human-readable TOML file at
`~/Library/Application Support/Dih/save.toml`. Existing `save.json` files are
migrated automatically after the TOML file is written successfully. Settings
are stored as `settings.toml`; existing `settings.json` files are migrated on
first load.