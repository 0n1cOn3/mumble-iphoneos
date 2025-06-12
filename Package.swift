// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Mumble",
    defaultLocalization: "en",
    platforms: [.iOS(.v12)],
    products: [
        .executable(name: "MumbleApp", targets: ["Mumble"])
    ],
    dependencies: [
        // Local dependency expected at MumbleKit
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", from: "3.3.0")
    ],
    targets: [
        .executableTarget(
            name: "Mumble",
            dependencies: ["MumbleKit"],
            path: "Source",
            exclude: ["Classes/LaunchScreen.storyboard", "MainWindow.xib"],
            sources: ["Classes", "main.m"],
            resources: [
                .copy("Classes/LaunchScreen.storyboard"),
                .copy("MainWindow.xib")
            ],
            publicHeadersPath: "Classes",
        ),
        .target(
            name: "MumbleKit",
            dependencies: ["OpenSSL"],
            path: "MumbleKit",
            exclude: ["src/MumbleKit.pch", "src/MumbleKit-MacOSX.plist"],
            sources: ["src"],
            publicHeadersPath: "src",
            cSettings: []
        )
    ]
)
