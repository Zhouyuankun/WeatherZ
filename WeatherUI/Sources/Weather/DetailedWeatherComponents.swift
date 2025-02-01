import SwiftUI
import WeatherData

public struct LargeSectionView: View {
    let mainTemp: Double
    let detailDescription: String
    let currentWeatherType: WeatherType
    
    public init(mainTemp: Double, detailDescription: String, currentWeatherType: WeatherType) {
        self.mainTemp = mainTemp
        self.detailDescription = detailDescription
        self.currentWeatherType = currentWeatherType
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            Image(currentWeatherType.imageAuto).resizable().aspectRatio(contentMode: .fit).frame(width: 140, height: 140)
            Text(currentWeatherType.description).font(.title)
            Text("\(Int(mainTemp - 273))°").font(.largeTitle)
            Text(detailDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, minHeight: 350)
        .cornerRadius(30)
        .padding(.horizontal)
    }
}

public struct TempSectionView: View {
    let tempMin: Double
    let tempMax: Double
    let feelsLike: Double
    let currentWeatherType: WeatherType
    
    public init(tempMin: Double, tempMax: Double, feelsLike: Double, currentWeatherType: WeatherType) {
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.feelsLike = feelsLike
        self.currentWeatherType = currentWeatherType
    }
    
    public var body: some View {
        HStack {
            SmallColView(text: String(localized: "Min temp"), iconName: "thermometer.low", value: Int(tempMin) - 273, sign: "°")
            SmallColView(text: String(localized: "Max temp"), iconName: "thermometer.high", value: Int(tempMax) - 273, sign: "°")
            SmallColView(text: String(localized: "Feels temp"), iconName: "thermometer.variable.and.figure", value: Int(feelsLike) - 273, sign: "°")
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct SmallColView: View {
    let text: String
    let iconName: String
    let value: Int
    let sign: String
    
    public init(text: String, iconName: String, value: Int, sign: String) {
        self.text = text
        self.iconName = iconName
        self.value = value
        self.sign = sign
    }
    
    public var body: some View {
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

public struct SeqTempSectionView: View {
    let futureWeathers: [ForecastResponse.FutureWeather]
    let currentWeatherType: WeatherType
    
    public init(futureWeathers: [ForecastResponse.FutureWeather], currentWeatherType: WeatherType) {
        self.futureWeathers = futureWeathers
        self.currentWeatherType = currentWeatherType
    }

    public var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 30) {
                ForEach(futureWeathers, id: \.dt) { monoWeather in
                    let date = Date(timeIntervalSince1970: monoWeather.dt)
                    let monoWeatherType = getWeatherType(from: monoWeather.weather[0].id)
                    let imageStr = date.isNight ? monoWeatherType.imageNight : monoWeatherType.imageDay
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
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct DailySectionView: View {
    //let forecastWeather: ForecastResponse
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
        VStack(spacing: 30) {
            ForEach(dailyWeathers, id: \.dt) { monoWeather in
                let monoWeatherType = getWeatherType(from: monoWeather.weatherID)
                HStack(spacing: 10) {
                    Text(monoWeather.dt.weekdayFullname)
                        .frame(width: 70)
                    Image(monoWeatherType.imageDay).resizable().aspectRatio(contentMode: .fit).frame(width: 30, height: 30)
                        .frame(width: 60)
                    Text("\(Int(monoWeather.tempMin) - 273)°")
                        .frame(width: 40)
                    
                    TempRange(minTempToday: Int(monoWeather.tempMin), maxTempToday: Int(monoWeather.tempMax), minTempGlobal: minDailyTemp, maxTempGlobal: maxDailyTemp)
                    
                    Text("\(Int(monoWeather.tempMax) - 273)°")
                        .frame(width: 40)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: CGFloat(dailyWeathers.count) * 60)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct TempRange: View {
    let lineHeight: CGFloat = 4.0
    let lineWidth: CGFloat = 80.0
    
    var minTempToday: Int
    var maxTempToday: Int
    
    var minTempGlobal: Int
    var maxTempGlobal: Int
    
    let _tempLineWidth: CGFloat = 40.0
    
    var scale: CGFloat {
        return CGFloat(lineWidth) / CGFloat(maxTempGlobal-minTempGlobal)
    }
    
    var startPos: CGFloat {
        return scale * CGFloat(minTempToday - minTempGlobal)
    }
    
    var endPos: CGFloat {
        return lineWidth - (scale * CGFloat(maxTempGlobal - maxTempToday))
    }
    
    let gradientColors = [
        Color(#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)),
        Color(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)),
        Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)),
        Color(#colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1))
    ]
    
    public var body: some View {
        ZStack (alignment: .leading) {

            // Temperature Scale Background
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)))
                .frame(
                    width: lineWidth,
                    height: lineHeight,
                    alignment: .center
                )
            
            // Temperature Gradient Line
            RoundedRectangle(cornerRadius: 10)
                .fill(LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(
                    maxWidth: lineWidth,
                    maxHeight: lineHeight
                )
                .mask(
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10).frame(width: endPos - startPos)
                    }
                    .frame(
                        width: lineWidth,
                        height: lineHeight,
                        alignment: .leading
                    )
                    .offset(x: startPos)
                )
        }
    }
}

public struct WindSectionView: View {
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double?
    let currentWeatherType: WeatherType
    
    public init(windSpeed: Double, windDeg: Int, windGust: Double?, currentWeatherType: WeatherType) {
        self.windSpeed = windSpeed
        self.windDeg = windDeg
        self.windGust = windGust
        self.currentWeatherType = currentWeatherType
    }

    public var body: some View {
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
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [currentWeatherType.primaryColor, currentWeatherType.secondaryColor]), startPoint: .bottom, endPoint: .top))
                    .rotationEffect(.degrees(Double(180 + windDeg)))
                    
            }
            .padding(.horizontal, 10)
            // Wind speed
            VStack {
                HStack {
                    Text("Wind speed")
                    Spacer()
                    Text(String(format: "%.2fm/s", windSpeed))
                       
                }
                .frame(maxHeight: .infinity)
                
                // Gust speed
                HStack {
                    Text("Wind gust")
                        
                    Spacer()
                    Text(String(format: "%.2fm/s", windGust ?? 0.0))
                       
                }
                .frame(maxHeight: .infinity)
                
                // Wind direction
                HStack {
                    Text("Direction")
                        
                    Spacer()
                    Text("\(windDeg)°")
                        
                }
                .frame(maxHeight: .infinity)
            }
            .padding(.horizontal, 10)
            .frame(height: 80)
            .font(.caption)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct Arrow: Shape {
    public func path(in rect: CGRect) -> Path {
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

public struct SunRiseSetView: View {
    let sunrise: Double
    let sunset: Double
    let currentWeatherType: WeatherType
    
    public init(sunrise: Double, sunset: Double, currentWeatherType: WeatherType) {
        self.sunrise = sunrise
        self.sunset = sunset
        self.currentWeatherType = currentWeatherType
    }
    
    public var body: some View {
        HStack {
            RingView(color1: currentWeatherType.primaryColor,color2: currentWeatherType.secondaryColor,
                     radius: 50, percent:
                        Date.now.percentInBeforeAfter(before: sunrise, after: sunset), show: .constant(true))
            VStack {
                HStack {
                    Text("Sunrise")
                    Spacer()
                    Text(Date(timeIntervalSince1970: sunrise).hourMinute)
                       
                }
                .frame(maxHeight: .infinity)
                
                // Gust speed
                HStack {
                    Text("Sunset")
                    Spacer()
                    Text(Date(timeIntervalSince1970: sunset).hourMinute)
                       
                }
                .frame(maxHeight: .infinity)
               
            }
            .padding(.horizontal, 10)
            .frame(height: 80)
            .font(.caption)
        }
        .frame(maxWidth: .infinity, minHeight: 150)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct HumiditySectionView: View {
    let humidity: Int
    let currentWeatherType: WeatherType
    
    public init(humidity: Int, currentWeatherType: WeatherType) {
        self.humidity = humidity
        self.currentWeatherType = currentWeatherType
    }
   
    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "humidity")
                Text("Humidity")
            }
            .font(.caption)
            
            Text("\(humidity)%")
                .font(.title)
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct PressureSectionView: View {
    let pressure: Int
    let currentWeatherType: WeatherType
    
    public init(pressure: Int, currentWeatherType: WeatherType) {
        self.pressure = pressure
        self.currentWeatherType = currentWeatherType
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "powermeter")
                Text("Pressure")
            }
            .font(.caption)
            
            Text("\(pressure)pa")
                .font(.title)
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct VisibilitySectionView: View {
    let visibility: Int
    let currentWeatherType: WeatherType
    
    public init(visibility: Int, currentWeatherType: WeatherType) {
        self.visibility = visibility
        self.currentWeatherType = currentWeatherType
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "eye")
                Text("Visibility")
            }
            .font(.caption)
            
            Text("\(visibility)m")
                .font(.title)
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct RainSectionView: View {
    let precipitation: Double
    let currentWeatherType: WeatherType
    
    public init(precipitation: Double, currentWeatherType: WeatherType) {
        self.precipitation = precipitation
        self.currentWeatherType = currentWeatherType
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "cloud.rain")
                Text("Rain precipitation")
            }
            .font(.caption)
            
            Text("\(String(format: "%.2f", precipitation))mm/h")
                .font(.title)
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct SnowSectionView: View {
    let precipitation: Double
    let currentWeatherType: WeatherType
    
    public init(precipitation: Double, currentWeatherType: WeatherType) {
        self.precipitation = precipitation
        self.currentWeatherType = currentWeatherType
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "cloud.snow")
                Text("Snow precipitation")
            }
            .font(.caption)

            Text("\(String(format: "%.2f", precipitation))mm/h")
                .font(.title)
            
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .modifier(WeatherCardModifier(weatherType: currentWeatherType))
    }
}

public struct RingView: View {
    var color1: Color
    var color2: Color
    var radius: CGFloat = 50
    var percent: Double = 0.5
        @Binding var show: Bool
        
    public var body: some View {
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

public struct WeatherCardModifier: ViewModifier {
    let weatherType: WeatherType
    var opacity: CGFloat
    var cornerRadius: CGFloat
    
    var primaryColor: Color {
        return weatherType.primaryColor
    }
    
    var secondaryColor: Color {
        return weatherType.secondaryColor
    }
    
    public init(weatherType: WeatherType, opacity: CGFloat = 0.2, cornerRadius: CGFloat = 30) {
        self.weatherType = weatherType
        self.opacity = opacity
        self.cornerRadius = cornerRadius
    }
    

    public func body(content: Content) -> some View {
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
