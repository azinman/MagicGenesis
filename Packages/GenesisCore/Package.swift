// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "GenesisCore",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "GenesisCore", targets: ["GenesisCore"]),
    ],
    dependencies: [
        .package(path: "../E68k"),
    ],
    targets: [
        .target(name: "GenesisCore", dependencies: ["E68k"]),
        .testTarget(name: "GenesisCoreTests", dependencies: ["GenesisCore"]),
    ]
)
