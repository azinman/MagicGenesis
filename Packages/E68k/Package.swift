// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "E68k",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "E68k", targets: ["E68k"]),
    ],
    targets: [
        .target(name: "E68k"),
        .testTarget(name: "E68kTests", dependencies: ["E68k"]),
    ]
)
