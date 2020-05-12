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
        .package(url: "../VJson", from: "1.2.0"),
        .package(url: "../SwifterSockets", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "SwifterLog",
            dependencies: ["VJson", "SwifterSockets"]
        )
    ]
)
