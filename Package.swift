// swift-tools-version:5.5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ether",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .macCatalyst(.v14),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        
        // 🎆 Ether
        .library(name: "Ether",
                 targets: ["Ether"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/1024jp/GzipSwift", from: "5.1.1"),
        .package(url: "https://github.com/vapor/vapor", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        // 🎆 Ether
        .target(name: "Ether",
                dependencies: [.product(name: "Gzip", package: "GzipSwift")]),
        .testTarget(
            name: "EtherTests",
            dependencies: ["Ether",
                           .product(name: "Vapor", package: "vapor"),
                          ],
            resources: [.copy("Resources/你好.jpeg")
                       ]),
    ]
)
