//
//  MultiCityView.swift
//  WeatherZ
//
//  Created by 周源坤 on 2022/2/1.
//

import SwiftUI
import CoreLocation
import SwiftData

struct MultiCityView: View {
    @Environment(LocationViewModel.self) var locationViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var currentWeatherViewModel = CurrentWeatherViewModel()
    
    @State private var presentWeatherPage: Bool = true
    
    @Query var allCities: [SubscribedCity]
    @Environment(\.modelContext) private var context
    
    @State var searchText: String = ""
    
    func updateLocation() async {
        locationViewModel.updateLoc()
    }
    
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(value: locationViewModel.localCity) {
                        CityCardView(cityInfo: locationViewModel.localCity)
                    }
                    .deleteDisabled(true)
                } header: {
                    Text("Current Location")
                }
                
                
                Section {
                    ForEach(allCities, id: \.id) { cityInfo in
                        NavigationLink(value: cityInfo.city) {
                            CityCardView(cityInfo: cityInfo.city)
                        }
                    }
                    .onDelete { offsets in
                        for i in offsets {
                            context.delete(allCities[i])
                        }
                    }
                } header: {
                    Text("Subscribed Locations")
                }
            }
            .navigationDestination(for: City.self) { city in
                HomeView(city: city)
                    .environment(currentWeatherViewModel)
            }
            .navigationTitle("WeatherZ")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: {
                        SearchCityView()
                    }, label: {
                        Image(systemName: "magnifyingglass")
                    })
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        try! context.delete(model: SubscribedCity.self)
                    }, label: {
                        Image(systemName: "trash")
                        
                    })
                    
                }
            }
        }
        .onChange(of: scenePhase, { _, newValue in
            if newValue == .active {
                Task {
                    await updateLocation() // Call when app becomes foreground
                }
            }
        })
    }
}

struct CityCardView: View {
    var cityInfo: City
    @State private var lastRefreshTime: Date? = nil
    
    @State private var currentWeatherViewModel = CurrentWeatherViewModel()
    
    var weatherType: WeatherType {
        return getWeatherType(from: currentWeatherViewModel.currentWeather.weather[0].id)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(cityInfo.name)
                    .font(.title)
                Spacer()
            }
            Spacer()
            Text("\(currentWeatherViewModel.currentWeather.weather[0].main)")
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [weatherType.primaryColor.opacity(1), weatherType.secondaryColor.opacity(1)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(5)
        .onAppear {
            Task {
                if let lastRefresh = lastRefreshTime, Date.now.timeIntervalSince(lastRefresh) < 60 {
                    print("Refresh skipped: Wait \(60 - Date.now.timeIntervalSince(lastRefresh)) seconds.")
                    return
                }
                
                // Update the last refresh time and load data
                lastRefreshTime = Date.now
                print("Refreshing weather data...")
                await currentWeatherViewModel.loadFromWeb(lon: cityInfo.lon, lat: cityInfo.lat)
            }
        }
        
    }
}

func fullCountryName(from countryCode: String) -> String? {
    let locale = Locale.current // Use a specific locale for the output language
    return locale.localizedString(forRegionCode: countryCode.uppercased())
}
