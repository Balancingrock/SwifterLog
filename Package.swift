// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwifterLog",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "SwifterLog", targets: ["SwifterLog"])
    ],
    dependencies: [
        .package(url: "https://github.com/Balancingrock/VJson", from: "0.16.0"),
        .package(url: "https://github.com/Balancingrock/SwifterSockets", from: "0.12.0")
    ],
    targets: [
        .target(
            name: "SwifterLog",
            dependencies: ["VJson", "SwifterSockets"]
        )
    ]
)
