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
        // 1. Hummingbird (Backend)
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", .upToNextMinor(from: "1.11.0")),
        
        // 2. Tokamak (Frontend)
        .package(url: "https://github.com/TokamakUI/Tokamak.git", from: "0.11.0"),
        
        // 3. System Fix
        .package(url: "https://github.com/apple/swift-system.git", exact: "1.2.1"),

        // 4. THE "ANTI-HANG" LIST (Pre-Resolved Dependencies)
        // We explicitly pin the networking stack to exact matching versions.
        // This stops the dependency solver from calculating; it just downloads what we tell it.
        .package(url: "https://github.com/apple/swift-nio.git", exact: "2.62.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", exact: "2.26.0"),
        .package(url: "https://github.com/apple/swift-nio-http2.git", exact: "1.29.0"),
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