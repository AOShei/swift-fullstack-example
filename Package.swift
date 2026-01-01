// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "TaskApp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Backend", targets: ["Backend"]),
    ],
    dependencies: [
        // Vapor web framework
        // (This automatically brings in swift-nio, swift-nio-ssl, swift-numerics, etc.)
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.0"),
        
        // Leaf templating engine
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        
        // Fluent ORM
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        
        // Fluent SQLite driver
        // (This automatically brings in sqlite-nio)
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
    ],
    targets: [
        // Assuming "Shared" is a local module you created
        .target(name: "Shared"),

        .executableTarget(
            name: "Backend",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                "Shared"
            ],
            resources: [
                .copy("Resources")
            ]
        ),
    ]
)
