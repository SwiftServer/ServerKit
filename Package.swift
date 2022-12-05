// swift-tools-version: 5.7
import PackageDescription

let package = Package(name: "ServerKit")

package.platforms = [
    .macOS(.v13),
]

package.dependencies = [

]

package.targets = [
    .target(name: "ServerKit"),
    .testTarget(name: "ServerKitTests", dependencies: [
        .target(name: "ServerKit"),
    ])
]

package.products = [
    .library(name: "ServerKit", targets: ["ServerKit"]),
]
