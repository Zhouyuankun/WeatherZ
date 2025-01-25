//
//  WeatherStore.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/5/25.
//

import SwiftUI

@Observable class CurrentWeatherViewModel {
    var currentWeather: CurrentWeatherResponse = WeatherService.shared.mockCurrentWeather()
    
    var updateStatus: UpdateStatus = .updated
    var updateTime: Date = .now
    
    @ObservationIgnored var updateInfoMessage: String {
        switch updateStatus {
        case .updating:
            return String(localized: "Trying to update the weather")
        case .updated:
            return String(localized: "The weather is updated at \(updateTime.hourMinuteSecond)")
        case .failed:
            return String(localized: "The weather failed to update")
        }
    }
    
    func loadFromWeb(lon: Double, lat: Double) async {
        updateStatus = .updating
        let result = await WeatherService.shared.loadCurrentWeather(lon: lon, lat: lat)
        switch result {
        case .success(let currentWeather):
            self.currentWeather = currentWeather
            updateStatus = .updated
            updateTime = .now
        case .failure(let error):
            updateStatus = .failed
            print(error.localizedDescription, "\(#function)")
        }
    }
}

@Observable class ForecastWeatherViewModel {
    var forecastWeather: ForecastResponse = WeatherService.shared.mockForecastWeather()
    var dailyWeather: [DailyGeneratedResponse]
    
    init() {
        dailyWeather = []
        Task {
            let grouped = await groupDatesByDay(dates: WeatherService.shared.mockForecastWeather().list)
            let result = await summaryFutureWeather(weatherData: grouped)
            await MainActor.run {
                dailyWeather = result
            }
        }
    }
    
    func loadFromWeb(lon: Double, lat: Double) async {
        let result = await WeatherService.shared.loadForecastWeather(lon: lon, lat: lat)
        switch result {
        case .success(let forecastWeather):
            self.forecastWeather = forecastWeather
            Task {
                let grouped = await groupDatesByDay(dates: forecastWeather.list)
                let result = await summaryFutureWeather(weatherData: grouped)
                await MainActor.run {
                    self.dailyWeather = result
                }
            }
        case .failure(let error):
            print(error.localizedDescription, "\(#function)")
        }
    }
}

struct DailyGeneratedResponse {
    let dt: Date
    let tempMax: Double
    let tempMin: Double
    let weatherID: Int
}

func groupDatesByDay(dates: [ForecastResponse.FutureWeather]) async -> [Date: [ForecastResponse.FutureWeather]] {
    let calendar = Calendar.current
    var groupedDates: [Date: [ForecastResponse.FutureWeather]] = [:]
    
    for date in dates {
        // Extract the start of the day for the current date
        let startOfDay = calendar.startOfDay(for: Date(timeIntervalSince1970: date.dt))
        
        // Group dates by their start of the day
        if groupedDates[startOfDay] != nil {
            groupedDates[startOfDay]?.append(date)
        } else {
            groupedDates[startOfDay] = [date]
        }
    }
    
    // Return the grouped dates as an array of arrays
    return groupedDates
}

func summaryFutureWeather(weatherData: [Date: [ForecastResponse.FutureWeather]]) async -> [DailyGeneratedResponse] {
    var result: [DailyGeneratedResponse] = []
    for (dt, monoday) in weatherData {
        var minTemp = monoday[0].main.tempMin
        var maxTemp = monoday[0].main.tempMax
        var weatherFrequency: [Int: Int] = [:]
        
        for monoWeather in monoday {
            if monoWeather.main.tempMin < minTemp {
                minTemp = monoWeather.main.tempMin
            }
            if monoWeather.main.tempMax > maxTemp {
                maxTemp = monoWeather.main.tempMax
            }
            weatherFrequency[monoWeather.weather[0].id, default: 0] += 1
        }
        let mostCommonWeatherID = weatherFrequency.max { $0.value < $1.value }!.key
        result.append(DailyGeneratedResponse(dt: dt, tempMax: maxTemp, tempMin: minTemp, weatherID: mostCommonWeatherID))
    }
    result.sort { $0.dt < $1.dt }
    return result
}

enum UpdateStatus {
    case updating
    case updated
    case failed
}
