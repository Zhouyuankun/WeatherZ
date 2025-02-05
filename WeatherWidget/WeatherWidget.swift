//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by 周源坤 on 1/25/25.
//

import WidgetKit
import SwiftUI
import WeatherData

struct WeatherDataProvider: TimelineProvider {
    
    let refreshDate = Date().addingTimeInterval(15 * 60)
    
    func getErrorEntry(errorMsg: String) -> WeatherDataEntry {
        WeatherDataEntry(date: .now, updateTime: .now, locationName: "", lat: 0.0, lon: 0.0, currentWeather: WeatherService.shared.mockCurrentWeather(), forecastWeather: WeatherService.shared.mockForecastWeather(), errorMsg: errorMsg)
    }
    
    func placeholder(in context: Context) -> WeatherDataEntry {
        WeatherDataEntry(date: .now, updateTime: .now, locationName: "Fetching data...", lat: 0.0, lon: 0.0, currentWeather: WeatherService.shared.mockCurrentWeather(), forecastWeather: WeatherService.shared.mockForecastWeather(), errorMsg: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (WeatherDataEntry) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherDataEntry>) -> ()) {
        guard let currentLocation = UserDefaults.loadLocation() else {
            let entry = getErrorEntry(errorMsg: "Last seen location not found, please open app to fetch current location.")
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
            return
        }
        
        Task {
            async let currentResult = WeatherService.shared.loadCurrentWeather(lon: currentLocation.lon, lat: currentLocation.lat)
            async let forecastResult = WeatherService.shared.loadForecastWeather(lon: currentLocation.lon, lat: currentLocation.lat)
            
            let currentWeather = await currentResult
            let forecastWeather = await forecastResult
            
            switch (currentWeather, forecastWeather) {
            case (.success(let currentResponse), .success(let forecastResponse)):
                let entry = WeatherDataEntry(
                    date: .now,
                    updateTime: .now,
                    locationName: currentLocation.localName,
                    lat: currentLocation.lat,
                    lon: currentLocation.lon,
                    currentWeather: currentResponse,
                    forecastWeather: forecastResponse,
                    errorMsg: nil
                )
                completion(Timeline(entries: [entry], policy: .after(refreshDate)))
            case (.failure(let error), _), (_, .failure(let error)): // Handle any failure
                let entry = getErrorEntry(errorMsg: error.localizedDescription)
                completion(Timeline(entries: [entry], policy: .after(refreshDate)))
            }
        }
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct WeatherDataEntry: TimelineEntry {
    var date: Date
    let updateTime: Date
    let locationName: String
    let lat: Double
    let lon: Double
    let currentWeather: CurrentWeatherResponse
    let forecastWeather: ForecastResponse
    
    let errorMsg: String?
}

struct WeatherWidgetEntryView : View {
    var entry: WeatherDataProvider.Entry
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            SmallWidgetView(entry: entry)
        case .systemLarge:
            SmallWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
        
    }
}

struct SmallWidgetView: View {
    let entry: WeatherDataProvider.Entry
    var currentWeatherType: WeatherType {
        return getWeatherType(from: entry.currentWeather.weather[0].id)
    }
    
    func windDescription(speed: Double) -> String {
        switch speed {
        case 0...0.3: return "No"
        case 0.3...1.5: return "Barely"
        case 1.5...3.3: return "Small"
        case 3.3...5.4: return "Pleasant"
        case 5.4...7.9: return "Steady"
        case 7.9...10.7: return "Strong"
        case 10.7...13.8: return "Big"
        case 13.8...17.1: return "Very strong"
        case 17.1...20.7: return "Powerful"
        case 20.7...24.4: return "Dangerous"
        case 24.4...28.4: return "Severe"
        default: return "Extreme"
        }
    }
    
    func windDirection(degrees: Int) -> String {
        let directions = [
            "N", "NNE", "NE", "ENE",
            "E", "ESE", "SE", "SSE",
            "S", "SSW", "SW", "WSW",
            "W", "WNW", "NW", "NNW"
        ]
        // Determine compass index (each point is 22.5°)
        let index = Int((Double(degrees) + 11.25) / 22.5) % 16
        return directions[index]
    }
    
    @ViewBuilder
    func successView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(entry.locationName)
                Spacer()
                Text("\(Int(entry.currentWeather.main.temp) - 273)°")
            }
            Divider()
            Label(currentWeatherType.description, systemImage: currentWeatherType.systemImageString)

            Group {
                Text("Wind: \(windDescription(speed: entry.currentWeather.wind.speed)) (\(windDirection(degrees: entry.currentWeather.wind.deg)))")
                Text("Humidity: \(entry.currentWeather.main.humidity)%")
            }
            .font(.footnote)
            Spacer()
            Text("UpdateTime: \(entry.updateTime.hourMinuteSecond)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) {
            Image(currentWeatherType.background)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    func errorView() -> some View {
        VStack {
            Text(entry.errorMsg!)
        }
    }
    
    var body: some View {
        if entry.errorMsg == nil {
            successView()
        } else {
            errorView()
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherDataProvider()) { entry in
            if #available(iOS 17.0, *) {
                WeatherWidgetEntryView(entry: entry)
            } else {
                WeatherWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
