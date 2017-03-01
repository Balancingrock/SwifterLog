import PackageDescription

let package = Package(
    name: "SwifterLog",
    dependencies: [
        .Package(url: "https://github.com/Balancingrock/CAsl", "0.1.0"),
        .Package(url: "../SwifterJSON", "0.9.17"),
        .Package(url: "../SwifterSockets", "0.9.15")
    ]
)
