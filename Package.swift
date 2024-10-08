// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SendbirdUserManager",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_13),
        .macCatalyst(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SendbirdUserManager",
            targets: ["SendbirdUserManager"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.0.6")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SendbirdUserManager",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]),
        
        .testTarget(
            name: "SendbirdUserManagerTests",
            dependencies: ["SendbirdUserManager"]),
    ]
)
