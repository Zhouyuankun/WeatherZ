//
//  SearchCityViewModel.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/11/25.
//

import Foundation

@Observable
class SearchCityViewModel {
    var searchText: String = ""
    var geoResult: [GeoAPIResponse] = []
    var searchOnDevice: Bool = false
    var showProgressIndicator: Bool = false
    
    func searchCity() async {
        showProgressIndicator = true
        var result: Result<[GeoAPIResponse], Error>
        if searchOnDevice {
            result = await LocationService.shared.getCityLocationInfo(cityName: searchText)
        } else {
            result = await WeatherService.shared.fetchCityCoordinate(city: searchText)
        }
        switch result {
        case .success(let geoInfos):
            self.geoResult = geoInfos
        case .failure(let error):
            print(error.localizedDescription, "\(#function)")
        }
        showProgressIndicator = false
    }
}