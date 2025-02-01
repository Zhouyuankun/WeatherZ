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
    targets: [
        .target(
            name: "WeatherData",
            path: ".",
            resources: [
                .process("Resources/current_weather.json"),
                .process("Resources/forecast_weather.json")
            ]
        )
    ]
)
