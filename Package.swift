// swift-tools-version: 6.3

import PackageDescription

let package = Package(
  name: "Dih",
  platforms: [
    .macOS(.v26)
  ],
  products: [
    .executable(
      name: "Dih",
      targets: ["Dih"]
    ),
    .library(
      name: "DihCore",
      targets: ["DihCore"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/mattt/swift-toml.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "DihCore",
      dependencies: [
        .product(name: "TOML", package: "swift-toml")
      ]
    ),
    .executableTarget(
      name: "Dih",
      dependencies: ["DihCore"],
      exclude: ["Resources/Info.plist"],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "DihCoreTests",
      dependencies: ["DihCore"]
    ),
  ]
)
