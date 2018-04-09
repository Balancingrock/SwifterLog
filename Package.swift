// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwifterLog",
    products: [
        .library(name: "SwifterLog", targets: ["SwifterLog"])
    ],
    dependencies: [
        .package(url: "https://github.com/Balancingrock/CAsl", from: "0.1.0"),
        .package(url: "https://github.com/Balancingrock/VJson", from: "0.11.0"),
        .package(url: "https://github.com/Balancingrock/SwifterSockets", from: "0.11.0")
    ],
    targets: [
        .target(
            name: "SwifterLog",
            dependencies: ["CAsl", "VJson", "SwifterSockets"]
        )
    ]
)
