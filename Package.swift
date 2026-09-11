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
        )
    ],
    targets: [
        .executableTarget(
            name: "Dih"
        )
    ]
)