//
//  WeatherStore.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/5/25.
//

import SwiftUI
import WeatherData

@Observable class MultiCityViewModel {
    var currentWeather: CurrentWeatherResponse = WeatherService.shared.mockCurrentWeather()
    
    func loadFromWeb(lon: Double, lat: Double) async {
        let result = await WeatherService.shared.loadCurrentWeather(lon: lon, lat: lat)
        switch result {
        case .success(let currentWeather):
            self.currentWeather = currentWeather
        case .failure(let error):
            print(error.localizedDescription, "\(#function)")
        }
    }
}


