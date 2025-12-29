// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TaskApp",
    platforms: [.macOS(.v13)], // Required for Vapor, ignored by Wasm
    products: [
        .executable(name: "Backend", targets: ["Backend"]),
        .executable(name: "Frontend", targets: ["Frontend"]),
    ],
    dependencies: [
        // Vapor for the Backend
        // URL must be a plain string, no Markdown formatting
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        
        // Tokamak for the Frontend (WebAssembly)
        .package(url: "https://github.com/TokamakUI/Tokamak.git", from: "0.11.0"),

        // Force use of swift-system 1.3.0 to avoid compiler parser errors 
        // with the newest version (1.4.0) on Linux.
        .package(url: "https://github.com/apple/swift-system.git", .upToNextMinor(from: "1.3.0"))
    ],
    targets: [
        // 1. Shared Logic (The Contract)
        .target(name: "Shared"),

        // 2. Backend (Server)
        .executableTarget(
            name: "Backend",
            dependencies: [
                // Note: The package name is derived from the URL (last part before .git)
                // So "https://github.com/vapor/vapor.git" becomes package: "vapor"
                .product(name: "Vapor", package: "vapor"),
                "Shared"
            ]
        ),

        // 3. Frontend (Web Client)
        .executableTarget(
            name: "Frontend",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak"),
                "Shared"
            ]
        ),
    ]
)