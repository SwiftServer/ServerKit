// swift-tools-version: 5.7
import PackageDescription

let package = Package(name: "ServerKit")

package.platforms = [
    .macOS(.v13),
]

package.dependencies = [
    .package(url: "https://github.com/Quick/Quick", from: "6.0.0"),
    .package(url: "https://github.com/Quick/Nimble", from: "11.0.0"),
]

package.targets = [
    .target(name: "ServerKit"),
    .testTarget(name: "ServerKitTests", dependencies: [
        .target(name: "ServerKit"),
        .product(name: "Quick", package: "Quick"),
        .product(name: "Nimble", package: "Nimble"),
    ])
]

package.products = [
    .library(name: "ServerKit", targets: ["ServerKit"]),
]
