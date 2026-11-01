// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SpeechCoachCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "SpeechCoachCore", targets: ["SpeechCoachCore"])],
    targets: [
        .target(name: "SpeechCoachCore"),
        .testTarget(name: "SpeechCoachCoreTests", dependencies: ["SpeechCoachCore"])
    ]
)
