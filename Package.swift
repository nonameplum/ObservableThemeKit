// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "ObservableThemeKit",
    platforms: [
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2),
        .macOS(.v10_10)
    ],
    products: [
        .library(
            name: "ObservableThemeKit",
            targets: ["ObservableThemeKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ObservableThemeKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "ObservableThemeKitTests",
            dependencies: ["ObservableThemeKit"],
            path: "Tests"
        ),
    ]
)
