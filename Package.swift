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
        // 1. Vapor (Back to the Standard)
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.0"),
        
        // 2. Tokamak (Frontend)
        .package(url: "https://github.com/TokamakUI/Tokamak.git", from: "0.11.0"),
        
        // 3. System Fix
        .package(url: "https://github.com/apple/swift-system.git", exact: "1.2.1"),

        // 4. THE "ANTI-HANG" LIST
        // Crucial: We keep these pinned to prevent the Codespace dependency solver 
        // from hanging on infinite calculations.
        .package(url: "https://github.com/apple/swift-nio.git", exact: "2.65.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", exact: "2.26.0"),
        .package(url: "https://github.com/apple/swift-nio-http2.git", exact: "1.29.0"),
    ],
    targets: [
        .target(name: "Shared"),

        .executableTarget(
            name: "Backend",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
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