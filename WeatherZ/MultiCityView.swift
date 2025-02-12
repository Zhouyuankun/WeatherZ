//
//  MultiCityView.swift
//  WeatherZ
//
//  Created by 周源坤 on 2022/2/1.
//

import SwiftUI
import CoreLocation
import SwiftData
import WeatherData

struct MultiCityView: View {
    @Environment(LocationViewModel.self) var locationViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var presentWeatherPage: Bool = true
    
    @Query var allCities: [SubscribedLocation]
    @Environment(\.modelContext) private var context
    
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let currentLocation = locationViewModel.localLocation {
                        CityCardView(cityInfo: currentLocation)
                            .background {
                                NavigationLink(value: currentLocation) {
                                    EmptyView() //for hidding navigation indicator
                                }
                            }
                        .deleteDisabled(true)
                    } else {
                        ProgressView()
                    }
                } header: {
                    Text("Current Location")
                }
                
                Section {
                    ForEach(allCities, id: \.id) { cityInfo in
                        CityCardView(cityInfo: cityInfo.location)
                            .background {
                                NavigationLink(value: cityInfo.location) {
                                    EmptyView()
                                }
                            }
                        .listRowSeparator(.hidden)
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
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .navigationDestination(for: Location.self) { city in
                DetailWeatherView(city: city)
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
                    NavigationLink(destination: {
                        SettingView()
                    }, label: {
                        Image(systemName: "gear")
                    })
                }
            }
        }
        .onAppear {
            Task {
                await locationViewModel.fetchLocation()
            }
        }
        .onChange(of: scenePhase, { _, newValue in
            if newValue == .active {
                Task {
                    await locationViewModel.fetchLocation()
                }
            }
        })
    }
}

struct CityCardView: View {
    var cityInfo: Location
    @State private var lastRefreshTime: Date? = nil
    
    @State var multiCityViewModel = MultiCityViewModel()
    
    var weatherType: WeatherType {
        return getWeatherType(from: multiCityViewModel.currentWeather.weather[0].id)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(cityInfo.name)
                    .font(.title)
                Spacer()
                Text(cityInfo.belongInfo)
                    .font(.caption)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(Int(multiCityViewModel.currentWeather.main.temp) - 273)°")
                    .font(.title)
                Spacer()
                Text("\(weatherType.description)")
                    .font(.caption)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [weatherType.primaryColor.opacity(1), weatherType.secondaryColor.opacity(1)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear {
            Task {
                if let lastRefresh = lastRefreshTime, Date.now.timeIntervalSince(lastRefresh) < 60 {
                    print("Refresh skipped: Wait \(60 - Date.now.timeIntervalSince(lastRefresh)) seconds.")
                    return
                }
                
                // Update the last refresh time and load data
                lastRefreshTime = Date.now
                print("Refreshing weather data...")
                await multiCityViewModel.loadFromWeb(lon: cityInfo.lon, lat: cityInfo.lat)
            }
        }
        
    }
}
