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
        // Hummingbird for Backend
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", .upToNextMinor(from: "1.11.0")),
        
        // Tokamak for Frontend
        .package(url: "https://github.com/TokamakUI/Tokamak.git", from: "0.11.0"),
        
        // Lock System to 1.2.1 to prevent Linux parser errors
        .package(url: "https://github.com/apple/swift-system.git", exact: "1.2.1")
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