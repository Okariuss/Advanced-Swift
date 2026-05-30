// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SetsRangesWorkspace",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SetsRangesWorkspace",
            targets: ["SetsRangesWorkspace"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SetsRangesWorkspace",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]
        ),

    ],
    swiftLanguageModes: [.v6]
)
