import PackageDescription

let package = Package(
    name: "SwifterLog",
    dependencies: [
        .Package(url: "https://github.com/Balancingrock/CAsl", "0.1.0"),
        .Package(url: "../SwifterJSON", "0.10.0"),
        .Package(url: "../SwifterSockets", "0.9.15")
    ]
)
