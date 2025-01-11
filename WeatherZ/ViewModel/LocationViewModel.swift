//
//  LocationViewModel.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/6/25.
//

import Foundation
import CoreLocation
import Combine

@Observable
class LocationViewModel {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var localCity: City = City(name: "Locating", localName: "", state: nil, country: "", lat: 0.0, lon: 0.0)
    
    var cancellables = Set<AnyCancellable>()
    
    @ObservationIgnored var locationService: LocationService
    var locationEnabled: Bool {
        return authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }
    
    init() {
        locationService = LocationService.shared
        locationService.authPub.sink { [weak self] status in
            self?.authorizationStatus = status
        }.store(in: &cancellables)
        locationService.localCityPub.sink { [weak self] city in
            self?.localCity = city
        }.store(in: &cancellables)
    }
    
    func updateLoc() {
        guard locationEnabled else {
            return
        }
        locationService.updateLoc()
    }
    
    func checkPermission() {
        locationService.requestPermission()
    }
}
