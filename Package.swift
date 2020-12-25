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
        .library(name: "RootController", targets: ["RootController"])
    ],
    targets: [
        .target(name: "Launcher", dependencies: ["TabProvider"]),
        .target(name: "TabProvider"),
        .target(name: "RootController", dependencies: ["TabProvider", "Launcher"]),
        .testTarget(
            name: "LauncherTests",
            dependencies: ["Launcher"]),
    ]
)
