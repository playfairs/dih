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
        )
    ],
    targets: [
        .target(
            name: "DihCore"
        ),
        .executableTarget(
            name: "Dih",
            dependencies: ["DihCore"],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "DihCoreTests",
            dependencies: ["DihCore"]
        )
    ]
)