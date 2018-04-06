import PackageDescription

let package = Package(
    name: "SwifterLog",
    dependencies: [
        .Package(url: "https://github.com/Balancingrock/CAsl", "0.1.0"),
        .Package(url: "https://github.com/Balancingrock/VJson", "0.10.10"),
        .Package(url: "https://github.com/Balancingrock/SwifterSockets", "0.10.11")
    ]
)
