import PackageDescription

let package = Package(
    name: "SwifterLog",
    dependencies: [
        .Package(url: "https://github.com/Balancingrock/CAsl", "0.1.0"),
<<<<<<< HEAD
        .Package(url: "https://github.com/Balancingrock/VJson", "0.10.7"),
        .Package(url: "https://github.com/Balancingrock/SwifterSockets", "0.10.8")
=======
        .Package(url: "../SwifterJSON", "0.10.3"),
        .Package(url: "https://github.com/Balancingrock/SwifterSockets", "0.10.5")
>>>>>>> dev
    ]
)
