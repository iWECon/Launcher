// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Launcher",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "Launcher", targets: ["Launcher"]),
        .library(name: "TabProvider", targets: ["TabProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/iWECon/RTNavigationController", from: "5.0.0"),
        .package(url: "https://github.com/iWECon/SegmentedController", from: "2.0.0")
    ],
    targets: [
        .target(name: "TabProvider"),
        .target(
            name: "Launcher",
            dependencies: [
                "TabProvider",
                "RTNavigationController",
                "SegmentedController"
            ]
        ),
        .testTarget(
            name: "LauncherTests",
            dependencies: ["Launcher"]),
    ]
)
