// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Mumble",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "MumbleApp", targets: ["Mumble"])
    ],
    dependencies: [
        // Local dependency expected at MumbleKit
    ],
    targets: [
        .target(
            name: "Mumble",
            dependencies: ["MumbleKit"],
            path: "Source",
            sources: ["Classes", "main.m"],
            resources: [
                .copy("Classes/LaunchScreen.storyboard"),
                .copy("MainWindow.xib")
            ],
            publicHeadersPath: "Classes",
        ),
        .target(
            name: "MumbleKit",
            path: "MumbleKit",
            publicHeadersPath: "."
        )
    ]
)
