//
//  SearchCityView.swift
//  WeatherZ
//
//  Created by 周源坤 on 2022/2/1.
//

import SwiftUI
import SwiftData

struct SearchCityView: View {
    @State var searchCityViewModel = SearchCityViewModel()
    @Environment(\.locale) var locale: Locale
    
    var body: some View {
        VStack {
            Picker("Seach city is in", selection: $searchCityViewModel.searchOnDevice) {
                Text("Domestic").tag(true)
                Text("Abroad").tag(false)
            }
            .frame(width: 200)
            .pickerStyle(.segmented)

            Form {
                TextField("Input city name", text: $searchCityViewModel.searchText)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await searchCityViewModel.searchCity()
                        }
                    }
            }
            .frame(height: 100)
        }
        List {
            Section {
                ForEach(searchCityViewModel.geoResult, id: \.self) { geoInfo in
                    SearchResultCell(geoInfo: geoInfo)
                }
            } footer: {
                Text("Found \(searchCityViewModel.geoResult.count) result on server")
            }
        }
        .overlay {
            if searchCityViewModel.showProgressIndicator {
                ProgressView()
            } else {
                Color.clear
            }
        }
        .navigationTitle("Search City")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchResultCell: View {
    let geoInfo: GeoAPIResponse
    @Environment(\.modelContext) private var context
    @Query var subscribedLocations: [SubscribedLocation]
    
    var foundInSubscription: Bool {
        for location in subscribedLocations {
            if location.name == geoInfo.localeName && location.city == geoInfo.city && location.state == geoInfo.state && location.country == geoInfo.country {
                return true
            }
        }
        return false
    }
    
    var body: some View {
        
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Location: \(geoInfo.localeName)")
                    if let city = geoInfo.city {
                        Text("City: \(city)")
                    }
                    if let state = geoInfo.state {
                        Text("Province: \(state)")
                    }
                    Text("Region: \(geoInfo.country)")
                }
                Spacer()
                Button(action: {
                    let location = SubscribedLocation(name: geoInfo.name, localName: geoInfo.localeName, city: geoInfo.city, state: geoInfo.state, country: geoInfo.country, lat: geoInfo.lat, lon: geoInfo.lon)
                    context.insert(location)
                }, label: {
                    Text("Subscribe")
                        .foregroundStyle(.white)
                        .padding()
                        .background(foundInSubscription ? .gray : .blue)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                })
                .buttonStyle(.borderless)
                .disabled(foundInSubscription)
            }
        }
    }
}

extension GeoAPIResponse {
    var fullName: String {
        if let state = self.state {
            return self.name+"\n"+state+"\n"+self.country
        } else {
            return self.name+"\n"+self.country
        }
    }
    
    var localeName: String {
        if let localNames = self.localNames, let localeRegion = Locale.current.region?.identifier, let localName = localNames[localeRegion] {
            return localName
        } else {
            return self.name
        }
    }
    
}
