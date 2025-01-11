//
//  WeatherService.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/5/25.
//

import Foundation

class WeatherService {
    private(set) static var shared = WeatherService()
    
    private var APIKEY: String
    
    init() {
        guard let filePath = Bundle.main.path(forResource: "APIKEY", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) as? [String: Any] else {
            fatalError("APIKEY.plist file not found or invalid format.")
        }
        
        // Retrieve the value for the key `APIKey`
        guard let apiKey = plist["APIKEY"] as? String else {
            fatalError("APIKEY key not found in APIKEY.plist.")
        }
        
        APIKEY = apiKey
    }
    
    func loadCurrentWeather(lon: Double, lat: Double) async -> Result<CurrentWeatherResponse, Error> {
        let currentWeatherURLPath = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(APIKEY)"
        print(currentWeatherURLPath)
        guard let url = URL(string: currentWeatherURLPath) else {
            return .failure(URLError(.badURL))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
       
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                return .failure(URLError(.badServerResponse))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let weatherResponse = try decoder.decode(CurrentWeatherResponse.self, from: data)
            return .success(weatherResponse)
        } catch {
            return .failure(error)
        }
    }
    
    func loadForecastWeather(lon: Double, lat: Double) async -> Result<ForecastResponse, Error> {
        let forecastWeatherURLPath = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(APIKEY)"
        print(forecastWeatherURLPath)
        guard let url = URL(string: forecastWeatherURLPath) else {
            return .failure(URLError(.badURL))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
       
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                return .failure(URLError(.badServerResponse))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let weatherResponse = try decoder.decode(ForecastResponse.self, from: data)
            return .success(weatherResponse)
        } catch {
            return .failure(error)
        }
    }
    
    func fetchCityCoordinate(city: String) async -> Result<[GeoAPIResponse], Error> {
        let geoAPIURLPath = "https://api.openweathermap.org/geo/1.0/direct?q=\(city)&limit=5&appid=\(APIKEY)"
        print(geoAPIURLPath)
        guard let url = URL(string: geoAPIURLPath) else {
            return .failure(URLError(.badURL))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                return .failure(URLError(.badServerResponse))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let geoResponse = try decoder.decode([GeoAPIResponse].self, from: data)
            return .success(geoResponse)
        } catch {
            return .failure(error)
        }
    }
    
    func fetchCityName(latitude: Double, longitude: Double) async -> Result<[GeoAPIResponse], Error> {
        let geoAPIURLPath = "https://api.openweathermap.org/geo/1.0/reverse?lat=\(latitude)&lon=\(longitude)&limit=5&appid=\(APIKEY)"
        print(geoAPIURLPath)
        guard let url = URL(string: geoAPIURLPath) else {
            return .failure(URLError(.badURL))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                return .failure(URLError(.badServerResponse))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let geoResponse = try decoder.decode([GeoAPIResponse].self, from: data)
            return .success(geoResponse)
        } catch {
            return .failure(error)
        }
    }
    
    func mockCurrentWeather() -> CurrentWeatherResponse {
        let fileUrl = Bundle.main.url(forResource: "current_weather", withExtension: "json")!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let response = try decoder.decode(CurrentWeatherResponse.self, from: Data(contentsOf: fileUrl))
            return response
        } catch {
            print(error.localizedDescription, "\(#function)")
            return defaultCurrentWeatherResponse
        }
    }
    
    func mockForecastWeather() -> ForecastResponse {
        let fileUrl = Bundle.main.url(forResource: "forecast_weather", withExtension: "json")!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let response = try decoder.decode(ForecastResponse.self, from: Data(contentsOf: fileUrl))
            return response
        } catch {
            print(error.localizedDescription, "\(#function)")
            return defaultForecastWeatherResponse
        }
    }
}

//https://api.openweathermap.org/data/2.5/weather?lat=35&lon=139&appid=4c5b613a9609b6ab7ab7fbd0b892eee5

let defaultCurrentWeatherResponse = CurrentWeatherResponse(coord: .init(lon: 7.367, lat: 45.133), weather: [.init(id: 501, main: "Rain", description: "moderate rain", icon: "10d")], base: "stations", main: .init(temp: 284.2, feelsLike: 282.93, tempMin: 283.06, tempMax: 286.82, pressure: 1021, humidity: 60, seaLevel: 1021, grndLevel: 910), visibility: 10000, wind: .init(speed: 4.09, deg: 121, gust: 3.47), rain: .init(oneH: 2.73), clouds: .init(all: 83), dt: 1726660758, sys: .init(type: 1, id: 6736, country: "IT", sunrise: 1726636384, sunset: 1726680975), timezone: 7200, id: 3165523, name: "Province of Turin", cod: 200)

let defaultForecastWeatherResponse = ForecastResponse(
    cod: "200",
    message: 0,
    cnt: 4,
    list: [
        .init(
            dt: 1661871600,
            main: .init(
                temp: 296.76,
                feelsLike: 296.98,
                tempMin: 296.76,
                tempMax: 297.87,
                pressure: 1015,
                seaLevel: 1015,
                grndLevel: 933,
                humidity: 69,
                tempKf: -1.11
            ),
            weather: [
                .init(id: 500, main: "Rain", description: "light rain", icon: "10d")
            ],
            clouds: .init(all: 100),
            wind: .init(speed: 0.62, deg: 349, gust: 1.18),
            visibility: 10000,
            pop: 0.32,
            rain: .init(threeH: 0.26),
            sys: .init(pod: "d"),
            dtTxt: "2022-08-30 15:00:00"
        ),
        .init(
            dt: 1661882400,
            main: .init(
                temp: 295.45,
                feelsLike: 295.59,
                tempMin: 292.84,
                tempMax: 295.45,
                pressure: 1015,
                seaLevel: 1015,
                grndLevel: 931,
                humidity: 71,
                tempKf: 2.61
            ),
            weather: [
                .init(id: 500, main: "Rain", description: "light rain", icon: "10n")
            ],
            clouds: .init(all: 96),
            wind: .init(speed: 1.97, deg: 157, gust: 3.39),
            visibility: 10000,
            pop: 0.33,
            rain: .init(threeH: 0.57),
            sys: .init(pod: "n"),
            dtTxt: "2022-08-30 18:00:00"
        ),
        .init(
            dt: 1661893200,
            main: .init(
                temp: 292.46,
                feelsLike: 292.54,
                tempMin: 290.31,
                tempMax: 292.46,
                pressure: 1015,
                seaLevel: 1015,
                grndLevel: 931,
                humidity: 80,
                tempKf: 2.15
            ),
            weather: [
                .init(id: 500, main: "Rain", description: "light rain", icon: "10n")
            ],
            clouds: .init(all: 68),
            wind: .init(speed: 2.66, deg: 210, gust: 3.58),
            visibility: 10000,
            pop: 0.7,
            rain: .init(threeH: 0.49),
            sys: .init(pod: "n"),
            dtTxt: "2022-08-30 21:00:00"
        ),
        .init(
            dt: 1662292800,
            main: .init(
                temp: 294.93,
                feelsLike: 294.83,
                tempMin: 294.93,
                tempMax: 294.93,
                pressure: 1018,
                seaLevel: 1018,
                grndLevel: 935,
                humidity: 64,
                tempKf: 0
            ),
            weather: [
                .init(id: 804, main: "Clouds", description: "overcast clouds", icon: "04d")
            ],
            clouds: .init(all: 88),
            wind: .init(speed: 1.14, deg: 17, gust: 1.57),
            visibility: 10000,
            pop: 0,
            rain: nil,
            sys: .init(pod: "d"),
            dtTxt: "2022-09-04 12:00:00"
        )
    ],
    city: .init(
        id: 3163858,
        name: "Zocca",
        coord: .init(lat: 44.34, lon: 10.99),
        country: "IT",
        population: 4593,
        timezone: 7200,
        sunrise: 1661834187,
        sunset: 1661882248
    )
)
