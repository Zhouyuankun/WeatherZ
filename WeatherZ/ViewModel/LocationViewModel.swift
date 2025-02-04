//
//  LocationViewModel.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/6/25.
//

import Foundation
import CoreLocation
import Combine
import WeatherData
import WidgetKit

@Observable
class LocationViewModel {
    var authorizationStatus: CLAuthorizationStatus
    var localLocation: Location?
    var locationService: AsyncLocationService
    
    init() {
        locationService = AsyncLocationService.shared
        authorizationStatus = AsyncLocationService.shared.authStatus
    }
    
    var locationEnabled: Bool {
        return AsyncLocationService.shared.authStatus == .authorizedAlways || AsyncLocationService.shared.authStatus == .authorizedWhenInUse
    }
    
    func fetchLocation() async {
        guard locationEnabled else {
            print("Please enable auth first")
            return
        }
        guard let location = await AsyncLocationService.shared.getCurrentLocation() else {
            return
        }
        localLocation = location
        UserDefaults.saveLocation(location: location)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func checkPermission() async {
        authorizationStatus = await AsyncLocationService.shared.requestPermission()
    }
}
