//
//  SearchCityView.swift
//  WeatherZ
//
//  Created by 周源坤 on 2022/2/1.
//

import SwiftUI
import SwiftData
import WeatherData
import WeatherUI

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
