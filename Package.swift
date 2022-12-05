// swift-tools-version: 5.7
import PackageDescription

let package = Package(name: "ServerKit")

package.platforms = [
    .macOS(.v13),
]

package.dependencies = [
    .package(url: "https://github.com/grpc/grpc-swift", from: "1.0.0"),
    .package(url: "https://github.com/vapor/vapor", from: "4.0.0"),
]

package.targets = [
    .target(name: "ServerKit", dependencies: [
        .product(name: "GRPC", package: "grpc-swift"),
        .product(name: "Vapor", package: "vapor"),
    ]),
    .testTarget(name: "ServerKitTests", dependencies: [
        .target(name: "ServerKit"),
    ]),

    // Examples
    .executableTarget(name: "ExampleGRPCServer", dependencies: [
        .target(name: "ServerKit"),
    ])
]

package.products = [
    .library(name: "ServerKit", targets: ["ServerKit"]),

    // Examples
    .executable(name: "ExampleGRPCServer", targets: ["ExampleGRPCServer"]),
]
