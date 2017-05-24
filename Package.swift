import PackageDescription

let package = Package(
    name: "SwifterLog",
    dependencies: [
        .Package(url: "https://github.com/Balancingrock/CAsl", "0.1.0"),
        .Package(url: "https://github.com/Balancingrock/SwifterJSON", "0.10.5"),
        .Package(url: "https://github.com/Balancingrock/SwifterSockets", "0.10.7")
    ]
)
