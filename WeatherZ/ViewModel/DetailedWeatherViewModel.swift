//
//  DetailedWeatherViewModel.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/28/25.
//


import SwiftUI
import WeatherData

@Observable class DetailedWeatherViewModel {
    var updateStatus: UpdateStatus = .updated
    var updateTime: Date = .now
    
    var updateInfoMessage: String {
        switch updateStatus {
        case .updating:
            return String(localized: "Trying to update the weather")
        case .updated:
            return String(localized: "The weather is updated at \(updateTime.hourMinuteSecond)")
        case .failed:
            return String(localized: "The weather failed to update")
        }
    }
    
    var currentWeather: CurrentWeatherResponse = WeatherService.shared.mockCurrentWeather()
    var forecastWeather: ForecastResponse = WeatherService.shared.mockForecastWeather()
    
    func loadForecastWeather(lon: Double, lat: Double) async {
        let result = await WeatherService.shared.loadForecastWeather(lon: lon, lat: lat)
        switch result {
        case .success(let forecastWeather):
            self.forecastWeather = forecastWeather
        case .failure(let error):
            print(error.localizedDescription, "\(#function)")
        }
    }
   
    func loadCurrentWeather(lon: Double, lat: Double) async {
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

enum UpdateStatus: String {
    case updating
    case updated
    case failed
}
