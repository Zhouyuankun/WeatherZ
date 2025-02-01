//
//  NetworkResponseModel.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/5/25.
//

import Foundation

// MARK: - Current Weather Response
public struct CurrentWeatherResponse: Codable {
    
    public let coord: Coord
    public let weather: [Weather]
    public let base: String
    public let main: Main
    public let visibility: Int?
    public let wind: Wind
    public let rain: Rain?
    public let snow: Snow?
    public let clouds: Clouds
    public let dt: Double
    public let sys: Sys
    public let timezone: Int
    public let id: Int
    public let name: String
    public let cod: Int
    
    public struct Coord: Codable {
        public let lon: Double
        public let lat: Double
    }
    
    // MARK: - Weather
    public struct Weather: Codable {
        public let id: Int
        public let main: String
        public let description: String
        public let icon: String
    }
    
    // MARK: - Main
    public struct Main: Codable {
        public let temp: Double
        public let feelsLike: Double
        public let tempMin: Double
        public let tempMax: Double
        public let pressure: Int
        public let humidity: Int
        public let seaLevel: Int?
        public let grndLevel: Int?
    }
    
    // MARK: - Wind
    public struct Wind: Codable {
        public let speed: Double
        public let deg: Int
        public let gust: Double?
    }
    
    // MARK: - Rain
    public struct Rain: Codable {
        public let oneH: Double?
        
        public enum CodingKeys: String, CodingKey {
            case oneH = "1h"
        }
    }
    
    public struct Snow: Codable {
        public let oneH: Double?
        
        public enum CodingKeys: String, CodingKey {
            case oneH = "1h"
        }
    }
    
    // MARK: - Clouds
    public struct Clouds: Codable {
        public let all: Int
    }
    
    // MARK: - Sys
    public struct Sys: Codable {
        public let type: Int?
        public let id: Int?
        public let country: String
        public let sunrise: Double
        public let sunset: Double
    }
}

// MARK: - 3Hour5Day Weather Response
public struct ForecastResponse: Codable {
    public let cod: String
    public let message: Int
    public let cnt: Int
    public let list: [FutureWeather]
    public let city: City
    
    public struct FutureWeather: Codable {
        public let dt: Double
        public let main: Main
        public let weather: [Weather]
        public let clouds: Clouds
        public let wind: Wind
        public let visibility: Int?
        public let pop: Double
        public let rain: Rain?
        public let snow: Snow?
        public let sys: Sys
        public let dtTxt: String
    }
    
    public struct Main: Codable {
        public let temp: Double
        public let feelsLike: Double
        public let tempMin: Double
        public let tempMax: Double
        public let pressure: Int
        public let seaLevel: Int
        public let grndLevel: Int
        public let humidity: Int
        public let tempKf: Double
    }
    
    public struct Weather: Codable {
        public let id: Int
        public let main: String
        public let description: String
        public let icon: String
    }
    
    public struct Clouds: Codable {
        public let all: Int
    }
    
    public struct Wind: Codable {
        public let speed: Double
        public let deg: Int
        public let gust: Double
    }
    
    public struct Rain: Codable {
        public let threeH: Double?
        
        public enum CodingKeys: String, CodingKey {
            case threeH = "3h"
        }
    }
    
    public struct Snow: Codable {
        public let threeH: Double?
        
        public enum CodingKeys: String, CodingKey {
            case threeH = "3h"
        }
    }
    
    public struct Sys: Codable {
        public let pod: String
    }
    
    public struct City: Codable {
        public let id: Int
        public let name: String
        public let coord: Coord
        public let country: String
        public let population: Int
        public let timezone: Int
        public let sunrise: Int
        public let sunset: Int
    }
    
    public struct Coord: Codable {
        public let lat: Double
        public let lon: Double
    }
}

// MARK: - Geo API Response (Name -> lat,lon | lat,lon -> Name)
public struct GeoAPIResponse: Codable, Hashable {
    public let name: String
    public let localNames: [String: String]?
    public let lat: Double
    public let lon: Double
    public let country: String
    public let state: String?
    public let city: String?

    public init(name: String,
                localNames: [String : String]?,
                lat: Double,
                lon: Double,
                country: String,
                state: String?,
                city: String?) {
        self.name = name
        self.localNames = localNames
        self.lat = lat
        self.lon = lon
        self.country = country
        self.state = state
        self.city = city
    }
}

public extension GeoAPIResponse {
    var localeName: String {
        if let localNames = self.localNames,
           let localeRegion = Locale.current.region?.identifier,
           let localName = localNames[localeRegion] {
            return localName
        } else {
            return self.name
        }
    }
}

public struct DailyGeneratedResponse: Sendable {
    public let dt: Date
    public let tempMax: Double
    public let tempMin: Double
    public let weatherID: Int
    
    public init(dt: Date, tempMax: Double, tempMin: Double, weatherID: Int) {
        self.dt = dt
        self.tempMax = tempMax
        self.tempMin = tempMin
        self.weatherID = weatherID
    }
}

public extension ForecastResponse {
    var dailyResponse: [DailyGeneratedResponse] {
        let grouped = groupDatesByDay(dates: self.list)
        let result = summaryFutureWeather(weatherData: grouped)
        return result
    }
}

func groupDatesByDay(dates: [ForecastResponse.FutureWeather]) -> [Date: [ForecastResponse.FutureWeather]] {
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

func summaryFutureWeather(weatherData: [Date: [ForecastResponse.FutureWeather]]) -> [DailyGeneratedResponse] {
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
