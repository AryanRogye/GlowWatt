// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "GlowWattIntentsKit",
    platforms: [.iOS(.v18), .macOS(.v13)],
    products: [
        .library(name: "GlowWattIntentsKit", targets: ["GlowWattIntentsKit"])
    ],
    targets: [
        .target(name: "GlowWattIntentsKit")
    ]
)
