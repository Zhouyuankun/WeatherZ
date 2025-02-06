//
//  File.swift
//  WeatherUI
//
//  Created by 周源坤 on 2/6/25.
//

import SwiftUI
import WeatherData

public struct WidgetSeqTempSectionView: View {
    let futureWeathers: [ForecastResponse.FutureWeather]
    let currentWeatherType: WeatherType
    
    public init(futureWeathers: [ForecastResponse.FutureWeather], currentWeatherType: WeatherType) {
        self.futureWeathers = Array(futureWeathers.prefix(5))
        self.currentWeatherType = currentWeatherType
    }

    public var body: some View {
        HStack {
            ForEach(futureWeathers, id: \.dt) { monoWeather in
                let date = Date(timeIntervalSince1970: monoWeather.dt)
                let monoWeatherType = getWeatherType(from: monoWeather.weather[0].id)
                let imageStr = monoWeatherType.systemImageString
                VStack(spacing: 5) {
                    Text(date.hourMinute)
                    Image(systemName: imageStr)
                    Text("\(Int(monoWeather.main.temp) - 273)°")
                        
                }
                .font(.footnote)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

public struct WidgetDailySectionView: View {
    let dailyWeathers: [DailyGeneratedResponse]
    let currentWeatherType: WeatherType
    
    public init(forecastWeather: ForecastResponse, currentWeatherType: WeatherType) {
        self.dailyWeathers = forecastWeather.dailyResponse
        self.currentWeatherType = currentWeatherType
    }
    
    var maxDailyTemp: Int {
        return dailyWeathers.map {Int($0.tempMax)}.max()!
    }
    var minDailyTemp: Int {
        return dailyWeathers.map {Int($0.tempMin)}.min()!
    }
    
    public var body: some View {
        VStack(spacing: 15) {
            ForEach(dailyWeathers, id: \.dt) { monoWeather in
                let monoWeatherType = getWeatherType(from: monoWeather.weatherID)
                HStack(spacing: 10) {
                    Text(monoWeather.dt.weekdayFullname)
                        .frame(width: 70)
                    Image(systemName: monoWeatherType.systemImageString)
                    Spacer()
                    Text("\(Int(monoWeather.tempMin) - 273)°")
                        .frame(width: 40)
                    
                    TempRange(minTempToday: Int(monoWeather.tempMin), maxTempToday: Int(monoWeather.tempMax), minTempGlobal: minDailyTemp, maxTempGlobal: maxDailyTemp)
                    
                    Text("\(Int(monoWeather.tempMax) - 273)°")
                        .frame(width: 40)
                }
            }
        }
        .font(.footnote)
    }
}
