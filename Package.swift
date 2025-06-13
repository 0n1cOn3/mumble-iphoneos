// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MumbleApp",
    defaultLocalization: "en",
    platforms: [ .iOS(.v16) ],
    products: [
        .executable(name: "MumbleApp", targets: ["MumbleApp"]),
        .library(name: "MumbleCore", targets: ["MumbleCore"])
    ],
    targets: [
        .target(
            name: "MumbleCore",
            path: "Sources/MumbleCore"
        ),
        .executableTarget(
            name: "MumbleApp",
            dependencies: ["MumbleCore"],
            path: "MumbleApp/Sources/MumbleApp"
        ),
        .testTarget(
            name: "MumbleAppTests",
            dependencies: ["MumbleApp"],
            path: "MumbleApp/Tests/MumbleAppTests"
        )
    ]
)
