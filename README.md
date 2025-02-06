# A SwiftUI Weather App

Weather infomation is from [OpenWeatherMap API](https://openweathermap.org/api)

For rebuild the project, first ensure your target is at least iOS 18.0, second ensure your get a free APIKEY from OpenWeatherMap API and save the API string in APIKEY.plist file. The file consists of one dictionary records, APIKEY is the key, the string you got from the website is the value.

The iOS development features in this app includes:

- SwiftData: For storing subscribed locations.
- Concurrency: Async/Await for fetching data from server
- MVVM: Service -> ViewModel -> View
- CoreLocation: For user locating service and Geo coder(Between Location name and latitude/longitude)
- Dark Mode: The UI supports both light and dark mode.
- Localization: Languege support for Chinese, English
- Swift package management: *WeatherData*, *WeatherUI* for Modular programming
- WidgetKit: Widget on HomeScreen

The function of this app:

- Always get current location and its weather
  
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/permission.jpg" width="210px" /><img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/multicity.png" width="210px" />
  
- Can add city from device location service, from OpenWeatherMap location service
  
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/search_dom.png" width="210px" /><img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/search_abr.png" width="210px" />
  
- Can browser the current weather infomation
  - Different color scheme for different weather
  - Temperature(min, max,feels)
  - Wind(speed, gust,direction)
  - Sun Position(sunset,sunrise,progress)
  - Humidity,Pressure,Visibility
  - Rain/Snow precipitation
  
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/detail_1.png" width="210px" />
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/detail_2.png" width="210px" />
  
  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/detail_3.png" width="210px" />
  
- Can add widget to Home Screen, in different size

  <img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/widget_large_medium.png" width="210px" /><img src="https://github.com/Zhouyuankun/WeatherZ/blob/main/README.assets/widget_small_icon.png" width="210px" />

### The image resources are from Web, which is not intended for commercial usage ! Study use only !





