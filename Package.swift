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
        .package(url: "[https://github.com/vapor/vapor.git](https://github.com/vapor/vapor.git)", from: "4.89.0"),
        // Tokamak for the Frontend (WebAssembly)
        .package(url: "[https://github.com/TokamakUI/Tokamak](https://github.com/TokamakUI/Tokamak)", from: "0.11.0"),
    ],
    targets: [
        // 1. Shared Logic (The Contract)
        .target(name: "Shared"),

        // 2. Backend (Server)
        .executableTarget(
            name: "Backend",
            dependencies: [
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