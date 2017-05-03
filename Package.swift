import PackageDescription

let package = Package(
    name: "SwifterLog",
    dependencies: [
        .Package(url: "https://github.com/Balancingrock/CAsl", "0.1.0"),
<<<<<<< HEAD
        .Package(url: "https://github.com/Balancingrock/SwifterJSON", "0.10.4"),
        .Package(url: "https://github.com/Balancingrock/SwifterSockets", "0.10.6")
=======
        .Package(url: "https://github.com/Balancingrock/SwifterJSON", "0.10.3"),
        .Package(url: "https://github.com/Balancingrock/SwifterSockets", "0.10.5")
>>>>>>> eec1ad7662311e3075a75b388b46709bce31b9f8
    ]
)
