//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by 周源坤 on 1/25/25.
//

import WidgetKit
import SwiftUI
import WeatherData

struct CurrentWeatherProvider: TimelineProvider {
    
    let refreshDate = Date().addingTimeInterval(15 * 60)
    
    func getErrorEntry(errorMsg: String) -> CurrentWeatherEntry {
        CurrentWeatherEntry(date: .now, updateTime: .now, locationName: "", lat: 0.0, lon: 0.0, temp: 273.0, tempMax: 273.0, tempMin: 273.0, errorMsg: errorMsg)
    }
    
    func placeholder(in context: Context) -> CurrentWeatherEntry {
        CurrentWeatherEntry(date: .now, updateTime: .now, locationName: "Fetching data...", lat: 0.0, lon: 0.0, temp: 273.0, tempMax: 273.0, tempMin: 273.0, errorMsg: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (CurrentWeatherEntry) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CurrentWeatherEntry>) -> ()) {
        guard let currentLocation = UserDefaults.loadLocation() else {
            let entry = getErrorEntry(errorMsg: "Last seen location not found, please open app to fetch current location.")
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
            return
        }
        
        Task {
            let result = await WeatherService.shared.loadCurrentWeather(lon: currentLocation.lon, lat: currentLocation.lat)
            switch result {
            case .success(let response):
                let entry = CurrentWeatherEntry(date: .now, updateTime: .now, locationName: currentLocation.localName, lat: currentLocation.lat, lon: currentLocation.lon, temp: response.main.temp, tempMax: response.main.tempMax, tempMin: response.main.tempMin, errorMsg: nil)
                completion(Timeline(entries: [entry], policy: .after(refreshDate)))
            case .failure(let error):
                let entry = getErrorEntry(errorMsg: error.localizedDescription)
                completion(Timeline(entries: [entry], policy: .after(refreshDate)))
            }
        }
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct CurrentWeatherEntry: TimelineEntry {
    var date: Date
    let updateTime: Date
    let locationName: String
    let lat: Double
    let lon: Double
    let temp: Double
    let tempMax: Double
    let tempMin: Double
    
    let errorMsg: String?
}

struct WeatherWidgetEntryView : View {
    var entry: CurrentWeatherProvider.Entry
    
    @ViewBuilder
    func successView() -> some View {
        VStack {
            HStack {
                Text("UpdateTime:")
                Text(entry.updateTime.hourMinuteSecond)
            }
            HStack {
                Text("locationName:")
                Text(entry.locationName)
            }
            HStack {
                Text("temp:")
                Text("\(Int(entry.temp) - 273)°")
            }
            HStack {
                Text("tempMax:")
                Text("\(Int(entry.tempMax) - 273)°")
            }
            HStack {
                Text("tempMin:")
                Text("\(Int(entry.tempMin) - 273)°")
            }
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
        StaticConfiguration(kind: kind, provider: CurrentWeatherProvider()) { entry in
            if #available(iOS 17.0, *) {
                WeatherWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WeatherWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
