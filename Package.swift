// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TaskApp",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Backend", targets: ["Backend"]),
    ],
    dependencies: [
        // Vapor web framework
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.0"),
        
        // Leaf templating engine for server-side rendering
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        
        // Fluent ORM & SQLite driver
        .package(url: "https://github.com/vapor/fluent.git", exact: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", exact: "4.6.0"),
    ],
    targets: [
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