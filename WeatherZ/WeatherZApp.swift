//
//  WeatherZApp.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/5/25.
//

import SwiftUI
import SwiftData
import WeatherData

@main
struct WeatherZApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SubscribedLocation.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
