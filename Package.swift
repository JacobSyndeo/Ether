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
        // 🎆 Ether
        .library(name: "Ether",
                 targets: ["Ether"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/themomax/swift-docc-plugin", branch: "add-extended-types-flag")
    ],
    targets: [
        // 🎆 Ether
        .target(name: "Ether",
                swiftSettings: [.unsafeFlags(["-emit-extension-block-symbols"])]
               ),
    ]
)
