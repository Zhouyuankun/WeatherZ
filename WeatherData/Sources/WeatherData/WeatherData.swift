//
//  File.swift
//  WeatherData
//
//  Created by 周源坤 on 1/25/25.
//

import SwiftUI

public enum WeatherType: String, Codable {
    case Thunderstorm
    case Drizzle
    case Rain
    case Snow
    case Atmosphere_dust
    case Atmosphere_fog
    case Atmosphere_wind
    case Clear_sun
    case Clear_cloudless
    case Clear_clouds
}

public struct WeatherSchemeDTO: Codable {
    let type: WeatherType
    let primaryColor: String
    let secondaryColor: String
    let imageAuto: String
    let imageDay: String
    let imageNight: String
    let backgound: String
}

// [WeatherType:WeatherSchemeInfo]
public struct WeatherSchemeInfo: Codable {
    let primaryColor: String
    let secondaryColor: String
    let imageAuto: String
    let imageDay: String
    let imageNight: String
    let backgound: String
}

public class WeatherSchemeManager {
    nonisolated(unsafe) static let shared = WeatherSchemeManager()
    
    private var weatherSchemeDict: [WeatherType:WeatherSchemeInfo] = [:]
    
    private init() {
        self.weatherSchemeDict = Self.getDefaultWeatherSchemeColor()
    }
    
    static func getDefaultWeatherSchemeColor() -> [WeatherType:WeatherSchemeInfo] {
        guard let url = Bundle.main.url(forResource: "WeatherSchemeColor", withExtension: "json"), let data = try? Data(contentsOf: url) else {
            fatalError("Error in loading weather scheme color config")
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let weatherData = try decoder.decode([WeatherSchemeDTO].self, from: data)
            var schemeDict: [WeatherType:WeatherSchemeInfo] = [:]
            for monoWeather in weatherData {
                schemeDict[monoWeather.type] = WeatherSchemeInfo(primaryColor: monoWeather.primaryColor, secondaryColor: monoWeather.secondaryColor, imageAuto: monoWeather.imageAuto, imageDay: monoWeather.imageDay, imageNight: monoWeather.imageNight, backgound: monoWeather.backgound)
            }
            return schemeDict
        } catch {
            fatalError("Decoding weather scheme color failed: \(error)")
        }
    }
    
    func getSchemeInfo(weatherType: WeatherType) -> WeatherSchemeInfo {
        guard let res = weatherSchemeDict[weatherType] else {
            fatalError("Missing \(weatherType) in dict \(weatherSchemeDict)")
        }
        return res
    }
}



public struct WeatherScheme {
    let id: Int
    let type: WeatherType
    let desc: String
    let primaryColor: String
    let secondaryColor: String
}

public func getWeatherType(from weatherCode: Int) -> WeatherType {
    switch weatherCode / 100 {
    case 2: return .Thunderstorm
    case 3: return .Drizzle
    case 5: return .Rain
    case 6: return .Snow
    case 7:
        switch weatherCode {
        case 701,711,721,741: return .Atmosphere_fog
        case 731,751,761,762: return .Atmosphere_dust
        case 771,781: return .Atmosphere_wind
        default: return .Atmosphere_fog
        }
    case 8:
        switch weatherCode {
        case 800: return .Clear_sun
        case 801,802: return .Clear_cloudless
        case 803,804: return .Clear_clouds
        default: return .Clear_sun
        }
    default:
        return .Clear_sun
    }
}

public extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}

public extension WeatherType {
    var primaryColor: Color {
        return Color.init(hex: WeatherSchemeManager.shared.getSchemeInfo(weatherType: self).primaryColor)
    }
    var secondaryColor: Color {
        return Color.init(hex: WeatherSchemeManager.shared.getSchemeInfo(weatherType: self).secondaryColor)
    }
    var imageAuto: String {
        return WeatherSchemeManager.shared.getSchemeInfo(weatherType: self).imageAuto
    }
    var imageDay: String {
        return WeatherSchemeManager.shared.getSchemeInfo(weatherType: self).imageDay
    }
    var imageNight: String {
        return WeatherSchemeManager.shared.getSchemeInfo(weatherType: self).imageNight
    }
    var background: String {
        return WeatherSchemeManager.shared.getSchemeInfo(weatherType: self).backgound
    }
    var description: String {
        switch self {
        case .Thunderstorm:
            String(localized: "Thunderstorm")
        case .Drizzle:
            String(localized: "Drizzle")
        case .Rain:
            String(localized: "Rain")
        case .Snow:
            String(localized: "Snow")
        case .Atmosphere_dust:
            String(localized: "Dust")
        case .Atmosphere_fog:
            String(localized: "Fog")
        case .Atmosphere_wind:
            String(localized: "Wind")
        case .Clear_sun:
            String(localized: "Sun")
        case .Clear_cloudless:
            String(localized: "Cloudless")
        case .Clear_clouds:
            String(localized: "Cloud")
        }
    }
}

