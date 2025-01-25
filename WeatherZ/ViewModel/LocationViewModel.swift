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
    var localLocation: Location?
    
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
        locationService.localLocationPub.sink { [weak self] location in
            self?.localLocation = location
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
