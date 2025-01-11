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
    @Environment(\.modelContext) private var context
    
    @Environment(\.locale) var locale: Locale
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            Form {
                TextField("Search City: ", text: $searchCityViewModel.searchText)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await searchCityViewModel.searchCity()
                        }
                    }
            }
            .frame(height: 100)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        searchCityViewModel.searchOnDevice.toggle()
                    }, label: {
                        Image(systemName: searchCityViewModel.searchOnDevice ? "iphone.circle.fill" : "iphone.circle")
                    })
                }
            }
        }
        List {
            Section {
                ForEach(searchCityViewModel.geoResult, id: \.self) { geoInfo in
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Location: \(geoInfo.localeName)")
                                Text("Province: \(geoInfo.state ?? "")")
                                Text("Region: \(geoInfo.country)")
                            }
                            Spacer()
                            Button(action: {
                                let city = SubscribedCity(name: geoInfo.name, localName: geoInfo.localeName, state: geoInfo.state, country: geoInfo.country, lat: geoInfo.lat, lon: geoInfo.lon)
                                context.insert(city)
                                print("Success")
                            }, label: {
                                Text("Subscribe")
                                    .foregroundStyle(.white)
                                    .padding()
                                    .background(.tint)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            })
                            .buttonStyle(.borderless)
                        }
                    }
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
