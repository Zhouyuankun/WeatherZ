//
//  NetworkResponseModel.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/5/25.
//

import Foundation

// MARK: - Current Weather Response
struct CurrentWeatherResponse: Codable {
    
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let rain: Rain?
    let clouds: Clouds
    let dt: Double
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
    
    
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
    
    // MARK: - Weather
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    // MARK: - Main
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let humidity: Int
        let seaLevel: Int?
        let grndLevel: Int?
    }
    
    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
        let gust: Double?
        
        // gust might not always be available
    }
    
    // MARK: - Rain
    struct Rain: Codable {
        let oneH: Double?
        
        enum CodingKeys: String, CodingKey {
            case oneH = "1h"
        }
    }
    
    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int
    }
    
    // MARK: - Sys
    struct Sys: Codable {
        let type: Int?
        let id: Int?
        let country: String
        let sunrise: Double
        let sunset: Double
    }
}

// MARK: - 3Hour5Day Weather Response
struct ForecastResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [MonoWeather]
    let city: City
    
    struct MonoWeather: Codable {
        let dt: Double
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let visibility: Int
        let pop: Double
        let rain: Rain?
        let sys: Sys
        let dtTxt: String
    }
    
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        let pressure: Int
        let seaLevel: Int
        let grndLevel: Int
        let humidity: Int
        let tempKf: Double
    }
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct Clouds: Codable {
        let all: Int
    }
    
    struct Wind: Codable {
        let speed: Double
        let deg: Int
        let gust: Double
    }
    
    struct Rain: Codable {
        let threeH: Double?
        
        enum CodingKeys: String, CodingKey {
            case threeH = "3h"
        }
    }
    
    struct Sys: Codable {
        let pod: String
    }
    
    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coord
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int
    }
    
    struct Coord: Codable {
        let lat: Double
        let lon: Double
    }
}

// MARK: - Geo API Response (Name -> lat,lon | lat,lon -> Name)
struct GeoAPIResponse: Codable, Hashable {
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    let city: String?
}
