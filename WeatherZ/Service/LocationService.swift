//
//  LocationService.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/6/25.
//

import Foundation
import CoreLocation
import Combine


class LocationService: NSObject, CLLocationManagerDelegate {
    private(set) static var shared = LocationService()
    
    private let locationManager: CLLocationManager
    
    var currentPlacemark: CLPlacemark?
    
    var locationPub = PassthroughSubject<CLLocation, Never>()
    var authPub = PassthroughSubject<CLAuthorizationStatus, Never>()
    var localCityPub = PassthroughSubject<City, Never>()
    
    override init() {
        locationManager = CLLocationManager()
        authPub.send(locationManager.authorizationStatus)
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func updateLoc() {
        locationManager.startUpdatingLocation()
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authPub.send(manager.authorizationStatus)
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            updateLoc()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastSeenLocation = locations.first!
        locationPub.send(lastSeenLocation)
        fetchCountryAndCity(for: lastSeenLocation)
        if let currentPlacemark = currentPlacemark {
            // Extract details from the placemark
            let cityName = currentPlacemark.locality ?? "Unknown"
            let stateName = currentPlacemark.administrativeArea ?? nil
            let countryCode = currentPlacemark.isoCountryCode ?? "Unknown"
            let latitude = lastSeenLocation.coordinate.latitude
            let longitude = lastSeenLocation.coordinate.longitude
            localCityPub.send(City(name: cityName, localName: cityName, state: stateName, country: countryCode, lat: latitude, lon: longitude))
        }
    }

    func fetchCountryAndCity(for location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
        }
    }
    
    func getCityNameByLocation(location: CLLocation) async throws -> String {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let currentPlacemark = placemarks.first {
            var output = ""
            if let cityName = currentPlacemark.locality {
                output = output + "\(cityName),"
            } else {
                output = output + "Unknown,"
            }
            if let countryName = currentPlacemark.isoCountryCode {
                output = output + "\(countryName)"
            } else {
                output = output + "Unknown"
            }
            return output
        }
        return "Unknown"
    }
    
    func getCityLocationInfo(cityName: String) async -> Result<[GeoAPIResponse], Error> {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(cityName)
            
            let filteredResponses = placemarks.compactMap { placemark -> GeoAPIResponse? in
                // Ensure location exists and has valid coordinates
                guard let location = placemark.location, let locality = placemark.locality, let country = placemark.country else { return nil }
                
                // Extract latitude and longitude
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                // Return GeoAPIResponse only if location info is available
                return GeoAPIResponse(
                    name: locality,
                    localNames: nil,
                    lat: latitude,
                    lon: longitude,
                    country: country,
                    state: nil
                )
            }
            return .success(filteredResponses)
        } catch {
            return .failure(error)
        }
        
    }
    
}

