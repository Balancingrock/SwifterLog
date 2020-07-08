// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SwifterLog",
    platforms: [.macOS(.v10_12), .iOS(.v8)],
    products: [
        .library(name: "SwifterLog", targets: ["SwifterLog"])
    ],
    dependencies: [
        .package(url: "https://github.com/Balancingrock/VJson", from: "1.2.0"),
        .package(url: "https://github.com/Balancingrock/SwifterSockets", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "SwifterLog",
            dependencies: ["VJson", "SwifterSockets"]
        )
    ],
    swiftLanguageVersions: [.v4, .v4_2, .v5]
)
