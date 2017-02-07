import PackageDescription

let package = Package(
    name: "SwifterLog",
    dependencies: [
        .Package(url: "https://github.com/Balancingrock/SwifterJSON", "0.9.16"),
        .Package(url: "https://github.com/Balancingrock/SwifterSockets", "0.9.12")
    ]
)
