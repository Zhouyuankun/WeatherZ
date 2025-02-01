//
//  HomeView.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/6/25.
//

import SwiftUI
import SwiftData
import WeatherData
import WeatherUI

struct DetailWeatherView: View {
    @State var detailedWeatherViewModel: DetailedWeatherViewModel = DetailedWeatherViewModel()
    
    @State private var lastRefreshTime: Date? = nil
    
    @Environment(\.scenePhase) private var scenePhase
    
    var city: Location
    
    @State private var showMultiCityView: Bool = false
    
    var currentWeatherType: WeatherType {
        return getWeatherType(from: detailedWeatherViewModel.currentWeather.weather[0].id)
    }
    
    func updateLocationAndWeather() async {
        await detailedWeatherViewModel.loadCurrentWeather(lon: city.lon, lat: city.lat)
        await detailedWeatherViewModel.loadForecastWeather(lon: city.lon, lat: city.lat)
    }

    var body: some View {
        ScrollView {
            LargeSectionView(mainTemp: detailedWeatherViewModel.currentWeather.main.temp, detailDescription: detailedWeatherViewModel.currentWeather.weather[0].description, currentWeatherType: currentWeatherType)
            SeqTempSectionView(futureWeathers: detailedWeatherViewModel.forecastWeather.list, currentWeatherType: currentWeatherType)
            DailySectionView(forecastWeather: detailedWeatherViewModel.forecastWeather, currentWeatherType: currentWeatherType)
            TempSectionView(tempMin: detailedWeatherViewModel.currentWeather.main.tempMin, tempMax: detailedWeatherViewModel.currentWeather.main.tempMax, feelsLike: detailedWeatherViewModel.currentWeather.main.feelsLike, currentWeatherType: currentWeatherType)
            WindSectionView(windSpeed: detailedWeatherViewModel.currentWeather.wind.speed, windDeg: detailedWeatherViewModel.currentWeather.wind.deg, windGust: detailedWeatherViewModel.currentWeather.wind.gust, currentWeatherType: currentWeatherType)
        
            SunRiseSetView(sunrise: detailedWeatherViewModel.currentWeather.sys.sunrise, sunset: detailedWeatherViewModel.currentWeather.sys.sunset, currentWeatherType: currentWeatherType)
            HStack(spacing: 0) {
                HumiditySectionView(humidity: detailedWeatherViewModel.currentWeather.main.humidity, currentWeatherType: currentWeatherType)
                PressureSectionView(pressure: detailedWeatherViewModel.currentWeather.main.pressure, currentWeatherType: currentWeatherType)
            }
            if let visibility = detailedWeatherViewModel.currentWeather.visibility {
                VisibilitySectionView(visibility: visibility, currentWeatherType: currentWeatherType)
            }
            if let rainPrecipitation = detailedWeatherViewModel.currentWeather.rain?.oneH {
                RainSectionView(precipitation: rainPrecipitation, currentWeatherType: currentWeatherType)
            }
            if let snowPrecipitation = detailedWeatherViewModel.currentWeather.snow?.oneH {
                SnowSectionView(precipitation: snowPrecipitation, currentWeatherType: currentWeatherType)
            }
            Text("\(detailedWeatherViewModel.updateInfoMessage)")
                .font(.subheadline)
        }
        .scrollIndicators(.hidden)
        .background {
            Image(currentWeatherType.background)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(.ultraThinMaterial)
                .ignoresSafeArea()
        }
        .navigationTitle(city.localName)
        .refreshable {
            await updateLocationAndWeather()
        }
        .onAppear {
            Task {
                if let lastRefresh = lastRefreshTime, Date.now.timeIntervalSince(lastRefresh) < 60 {
                    print("Refresh skipped: Wait \(60 - Date.now.timeIntervalSince(lastRefresh)) seconds.")
                    return
                }
                
                // Update the last refresh time and load data
                lastRefreshTime = Date.now
                print("Refreshing weather data...")
                await updateLocationAndWeather()
            }
        }
        .onChange(of: scenePhase, { _, newValue in
            if newValue == .active {
                Task {
                    await updateLocationAndWeather() // Call when app becomes foreground
                }
            }
        })
    }
}
