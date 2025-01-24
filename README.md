# A SwiftUI Weather App

Weather infomation is from [OpenWeatherMap API](https://openweathermap.org/api)

For rebuild the project, first ensure your target is at least iOS 18.0, second ensure your get a free APIKEY from OpenWeatherMap API and save the API string in APIKEY.plist file. The file consists of one dictionary records, APIKEY is the key, the string you got from the website is the value.

The iOS development features in this app includes:

- SwiftData: For storing subscribed locations.
- Concurrency: Async/Await for fetching data from server
- MVVM: Service -> ViewModel -> View
- Combine: For Reactive Programming from Service to ViewModel
- CoreLocation: For user locating service and Geo transforms(Between Location name and latitude/longitude)
- Dark Mode: The UI supports both light and dark mode.
- Localization: Languege support for Chinese, English

The function of this app:

- Always get current location and its weather
  
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/permission.jpg" width="210px" /><img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/main.jpg" width="210px" />
  
- Can add city from server GeoInfo or device GeoInfo(switch by top right button)
  
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/search.jpg" width="210px" />
  
- Can browser the current weather infomation
  - Different color scheme for different weather
  - Temperature(min, max,feels)
  - Wind(speed, gust,direction)
  - Sun Position(sunset,sunrise,progress)
  - Humidity,Pressure,Visibility
    
  
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/weather1.jpg" width="210px" />
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/weather2.jpg" width="210px" />
  
### The image resources are from Web, which is not intended for commercial usage ! Study use only !





