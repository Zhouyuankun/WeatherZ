//
//  HomeView.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/6/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(CurrentWeatherViewModel.self) var currentWeatherViewModel
    @State var forecastWeatherViewModel: ForecastWeatherViewModel = ForecastWeatherViewModel()
    
    @State private var lastRefreshTime: Date? = nil
    
    @Environment(\.scenePhase) private var scenePhase
    
    var city: Location
    
    @State private var showMultiCityView: Bool = false
    
    var weatherType: WeatherType {
        return getWeatherType(from: currentWeatherViewModel.currentWeather.weather[0].id)
    }
    
    func updateLocationAndWeather() async {
        await currentWeatherViewModel.loadFromWeb(lon: city.lon, lat: city.lat)
        await forecastWeatherViewModel.loadFromWeb(lon: city.lon, lat: city.lat)
    }

    var body: some View {
        ScrollView {
            LargeSectionView(response: currentWeatherViewModel.currentWeather)
            SeqTempSectionView(response: forecastWeatherViewModel.forecastWeather, curRes: currentWeatherViewModel.currentWeather)
            DailySectionView(response: forecastWeatherViewModel.dailyWeather, curRes: currentWeatherViewModel.currentWeather)
            TempSectionView(response: currentWeatherViewModel.currentWeather)
            WindSectionView(response: currentWeatherViewModel.currentWeather)
            SunRiseSetView(response: currentWeatherViewModel.currentWeather)
            HStack(spacing: 0) {
                HumiditySectionView(response: currentWeatherViewModel.currentWeather)
                PressureSectionView(response: currentWeatherViewModel.currentWeather)
            }
            VisibilitySectionView(response: currentWeatherViewModel.currentWeather)
            Text("\(currentWeatherViewModel.updateInfoMessage)")
                .font(.subheadline)
        }
        .background {
            Image(weatherType.background)
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
//        .toolbar {
//            ToolbarItem(placement: .topBarTrailing) {
//                Text("\(currentWeatherViewModel.updateStatus)")
//                    .font(.subheadline)
//            }
//        }
    }
}

struct LargeSectionView: View {
    var response: CurrentWeatherResponse
    @Environment(LocationViewModel.self) var locationViewModel
    
    var weatherType: WeatherType {
        return getWeatherType(from: response.weather[0].id)
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(weatherType.imageAuto).resizable().aspectRatio(contentMode: .fit).frame(width: 140, height: 140)
            Text(weatherType.description).font(.title)
            Text("\(Int(response.main.temp - 273))°").font(.largeTitle)
            Text(response.weather[0].description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, minHeight: 350)
        .cornerRadius(30)
        .padding(.horizontal)
    }
}

struct TempSectionView: View {
    var response: CurrentWeatherResponse
    
    var body: some View {
        HStack {
            SmallColView(text: String(localized: "Min temp"), iconName: "thermometer.low", value: Int(response.main.tempMin) - 273, sign: "°")
            SmallColView(text: String(localized: "Max temp"), iconName: "thermometer.high", value: Int(response.main.tempMax) - 273, sign: "°")
            SmallColView(text: String(localized: "Feels temp"), iconName: "thermometer.variable.and.figure", value: Int(response.main.feelsLike) - 273, sign: "°")
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .modifier(WeatherCardModifier(weatherType: getWeatherType(from: response.weather[0].id)))
    }
}

struct SmallColView: View {
    let text: String
    let iconName: String
    let value: Int
    let sign: String
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: iconName)
                Text(text)
            }
            .font(.caption)
            
            Text("\(value)\(sign)")
                .font(.title)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SeqTempSectionView: View {
    var response: ForecastResponse
    var curRes: CurrentWeatherResponse
    
    var weatherType: WeatherType {
        return getWeatherType(from: curRes.weather[0].id)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 30) {
                ForEach(response.list, id: \.dt) { monoWeather in
                    let date = Date(timeIntervalSince1970: monoWeather.dt)
                    let imageStr = date.isNight ? weatherType.imageNight : weatherType.imageDay
                    VStack(spacing: 10) {
                        Text(date.hourMinute)
                        Image(imageStr).resizable().aspectRatio(contentMode: .fit).frame(width: 30, height: 30)
                        Text("\(Int(monoWeather.main.temp) - 273)°")
                            
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .modifier(WeatherCardModifier(weatherType: weatherType))
    }
}

struct DailySectionView: View {
    var response: [DailyGeneratedResponse]
    var curRes: CurrentWeatherResponse
    
    var weatherType: WeatherType {
        return getWeatherType(from: curRes.weather[0].id)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            ForEach(response, id: \.dt) { monoWeather in
                HStack(spacing: 10) {
                    Text(monoWeather.dt.weekdayFullname)
                        .frame(width: 100)
                        
                    Image(weatherType.imageDay).resizable().aspectRatio(contentMode: .fit).frame(width: 30, height: 30)
                        .frame(width: 100)
                    Text("\(Int(monoWeather.tempMin) - 273)°")
                        .frame(width: 50)
                    Text("\(Int(monoWeather.tempMax) - 273)°")
                        .frame(width: 50)
                        
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: CGFloat(response.count) * 60)
        .modifier(WeatherCardModifier(weatherType: weatherType))
    }
}

struct WindSectionView: View {
    var response: CurrentWeatherResponse
    
    var weatherType: WeatherType {
        return getWeatherType(from: response.weather[0].id)
    }
    
    var body: some View {
        HStack {
            //Wind Clock
            ZStack {
                Circle()
                    .stroke(Color(uiColor: .label).opacity(0.5), lineWidth: 2)
                    .frame(width: 100, height: 80)
                
                // Directional Labels
                VStack {
                    Text("North")
                    Spacer()
                    Text("South")
                }
                .frame(height: 120)
                
                HStack {
                    Text("West")
                    Spacer()
                    Text("East")
                        
                }
                .frame(width: 120)
                
                
                Arrow()
                    .frame(width: 15, height: 50)
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [weatherType.primaryColor, weatherType.secondaryColor]), startPoint: .bottom, endPoint: .top))
                    .rotationEffect(.degrees(Double(180 + response.wind.deg)))
                    
            }
            .padding(.horizontal, 10)
            // Wind speed
            VStack {
                HStack {
                    Text("Wind speed")
                    Spacer()
                    Text(String(format: "%.2fm/s", response.wind.speed))
                       
                }
                .frame(maxHeight: .infinity)
                
                // Gust speed
                HStack {
                    Text("Wind gust")
                        
                    Spacer()
                    Text(String(format: "%.2fm/s", response.wind.gust ?? 0.0))
                       
                }
                .frame(maxHeight: .infinity)
                
                // Wind direction
                HStack {
                    Text("Direction")
                        
                    Spacer()
                    Text("\(response.wind.deg)°")
                        
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 10)
            .frame(height: 80)
            .font(.caption)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .modifier(WeatherCardModifier(weatherType: weatherType))
    }
}

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width / 3, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 2 / 3, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 2 / 3, y: rect.minY + rect.height / 3))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height / 3))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + rect.height / 3))
        path.addLine(to: CGPoint(x: rect.minX + rect.width / 3, y: rect.minY + rect.height / 3))
        path.addEllipse(in: CGRect(origin: CGPoint(x: rect.minX, y: rect.maxY), size: CGSize(width: rect.width, height: rect.width)))
        return path
    }
}

struct SunRiseSetView: View {
    let response: CurrentWeatherResponse
    
    var weatherType: WeatherType {
        return getWeatherType(from: response.weather[0].id)
    }
    
    var body: some View {
        HStack {
            RingView(color1: weatherType.primaryColor,color2: weatherType.secondaryColor,
                     radius: 50, percent:
                        Date.now.percentInBeforeAfter(before: response.sys.sunrise, after: response.sys.sunset), show: .constant(true))
            VStack {
                HStack {
                    Text("Sunrise")
                    Spacer()
                    Text(Date(timeIntervalSince1970: response.sys.sunrise).hourMinute)
                       
                }
                .frame(maxHeight: .infinity)
                
                // Gust speed
                HStack {
                    Text("Sunset")
                    Spacer()
                    Text(Date(timeIntervalSince1970: response.sys.sunset).hourMinute)
                       
                }
                .frame(maxHeight: .infinity)
               
            }
            .padding(.horizontal, 10)
            .frame(height: 80)
            .font(.caption)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .modifier(WeatherCardModifier(weatherType: weatherType))
    }
}

struct HumiditySectionView: View {
    let response: CurrentWeatherResponse
    
    var weatherType: WeatherType {
        return getWeatherType(from: response.weather[0].id)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "humidity")
                Text("Humidity")
            }
            .font(.caption)
            
            Text("\(response.main.humidity)%")
                .font(.title)
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .modifier(WeatherCardModifier(weatherType: weatherType))
    }
}

struct PressureSectionView: View {
    let response: CurrentWeatherResponse
    
    var weatherType: WeatherType {
        return getWeatherType(from: response.weather[0].id)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "powermeter")
                Text("Pressure")
            }
            .font(.caption)
            
            Text("\(response.main.pressure)pa")
                .font(.title)
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .modifier(WeatherCardModifier(weatherType: weatherType))
    }
}

struct VisibilitySectionView: View {
    let response: CurrentWeatherResponse
    
    var weatherType: WeatherType {
        return getWeatherType(from: response.weather[0].id)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "eye")
                Text("Visibility")
            }
            .font(.caption)
            
            Text("\(response.visibility)m")
                .font(.title)
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .modifier(WeatherCardModifier(weatherType: weatherType))
    }
}

struct RingView: View {
    var color1: Color
    var color2: Color
    var radius: CGFloat = 50
    var percent: Double = 0.5
        @Binding var show: Bool
        
        var body: some View {
            let multiplier = radius / 22
            let progress = 1 - percent / 2
            
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.1), style: StrokeStyle(lineWidth: 5 * multiplier))
                    .frame(width: 2 * radius, height: 2 * radius)
                
                Circle()
                    .trim(from: show ? progress : 1, to: 1)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .topTrailing, endPoint: .bottomLeading),
                        style: StrokeStyle(lineWidth: 5 * multiplier, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0)
                    )
                    .rotationEffect(Angle(degrees: 180))
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                    .frame(width: 2 * radius, height: 2 * radius)
                    .shadow(color: Color(color2).opacity(0.1), radius: 3 * multiplier, x: 0, y: 3 * multiplier)
                
                if percent > 0.01 && percent < 0.99 {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .offset(x: -cos(Double.pi * percent) * radius, y: -sin(Double.pi * percent) * radius)
                        .shadow(color: .white, radius: 2, y: 2)
                }
            }
            .padding(.horizontal, 10)
        }
}

struct WeatherCardModifier: ViewModifier {
    let weatherType: WeatherType
    var opacity: CGFloat = 0.2
    var cornerRadius: CGFloat = 30
    
    var primaryColor: Color {
        return weatherType.primaryColor
    }
    
    var secondaryColor: Color {
        return weatherType.secondaryColor
    }
    

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [primaryColor.opacity(opacity), secondaryColor.opacity(opacity)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(cornerRadius)
            .shadow(color: secondaryColor, radius: 20, x: 0, y: 20)
            .padding(.horizontal, 10)
    }
}
