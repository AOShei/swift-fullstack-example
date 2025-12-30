// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TaskApp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Backend", targets: ["Backend"]),
        .executable(name: "Frontend", targets: ["Frontend"]),
    ],
    dependencies: [
        // 1. Hummingbird (The lightweight Vapor alternative)
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "1.0.0"),
        
        // 2. Tokamak (Frontend)
        .package(url: "https://github.com/TokamakUI/Tokamak.git", from: "0.11.0"),
        
        // 3. System Fix (Keep this to prevent Linux parser errors)
        .package(url: "https://github.com/apple/swift-system.git", .upToNextMinor(from: "1.3.0"))
    ],
    targets: [
        .target(name: "Shared"),

        .executableTarget(
            name: "Backend",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                "Shared"
            ]
        ),

        .executableTarget(
            name: "Frontend",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak"),
                "Shared"
            ]
        ),
    ]
)