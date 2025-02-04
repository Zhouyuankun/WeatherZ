// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WeatherData",
    platforms: [
        .iOS(.v18)
        ],
    products: [
        .library(
            name: "WeatherData",
            type: .dynamic,
            targets: ["WeatherData"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/AsyncSwift/AsyncLocationKit.git", .upToNextMinor(from: "1.6.4"))
    ],
    targets: [
        .target(
            name: "WeatherData",
            dependencies: [
                .product(name: "AsyncLocationKit", package: "AsyncLocationKit", condition: nil)
            ],
            path: ".",
            resources: [
                .process("Resources/current_weather.json"),
                .process("Resources/forecast_weather.json")
            ]
        )
    ]
)
