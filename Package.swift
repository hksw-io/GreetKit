// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "GreetKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(
            name: "GreetKit",
            targets: ["GreetKit"]),
    ],
    targets: [
        .target(
            name: "GreetKit"),
        .testTarget(
            name: "GreetKitTests",
            dependencies: ["GreetKit"]),
    ])
