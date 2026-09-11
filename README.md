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

Progress is stored in `~/Library/Application Support/Dih/`; settings are stored
separately in the same application-support directory.