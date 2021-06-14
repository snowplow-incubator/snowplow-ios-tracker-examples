// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dependencies",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Dependencies",
            targets: ["Dependencies"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SnowplowTracker", url: "https://github.com/snowplow/snowplow-objc-tracker", .branch("master")),
        // .package(name: "SnowplowTracker", path: "../../../../snowplow-objc-tracker"),
        // .package(name: "SnowplowTracker", path: "../../../.."),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Dependencies",
            dependencies: ["SnowplowTracker"]),
    ]
)
