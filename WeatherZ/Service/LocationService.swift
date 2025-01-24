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
    var localLocationPub = PassthroughSubject<Location, Never>()
    
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
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(lastSeenLocation) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
        }
        if let currentPlacemark = currentPlacemark {
            printPlacemarkDetails(currentPlacemark)
            // Extract details from the placemark
            let cityName = currentPlacemark.subLocality ?? currentPlacemark.locality ?? "Unknown"
            let stateName = currentPlacemark.administrativeArea ?? nil
            let countryName = currentPlacemark.country ?? "Unknown"
            let latitude = lastSeenLocation.coordinate.latitude
            let longitude = lastSeenLocation.coordinate.longitude
            localLocationPub.send(Location(name: cityName, localName: cityName, state: stateName, country: countryName, lat: latitude, lon: longitude, city: currentPlacemark.locality))
            //end updating
            manager.stopUpdatingLocation()
        }
    }
    
    func getCityLocationInfo(cityName: String) async -> Result<[GeoAPIResponse], Error> {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(cityName)
            
            let filteredResponses = placemarks.compactMap { placemark -> GeoAPIResponse? in
                // Ensure location exists and has valid coordinates
                guard let location = placemark.location, let locality = placemark.subLocality ?? placemark.locality, let country = placemark.country else { return nil }
                
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
                    state: placemark.administrativeArea,
                    city: placemark.locality
                )
            }
            return .success(filteredResponses)
        } catch {
            return .failure(error)
        }
        
    }
    
}

//Show all the location infomation
func printPlacemarkDetails(_ placemark: CLPlacemark) {
    print("=== CLPlacemark Details ===")
    if let name = placemark.name {
        print("Name: \(name)")
    }
    if let thoroughfare = placemark.thoroughfare {
        print("Street: \(thoroughfare)")
    }
    if let subThoroughfare = placemark.subThoroughfare {
        print("Sub-Thoroughfare: \(subThoroughfare)")
    }
    if let locality = placemark.locality {
        print("City: \(locality)")
    }
    if let subLocality = placemark.subLocality {
        print("Sub-Locality: \(subLocality)")
    }
    if let administrativeArea = placemark.administrativeArea {
        print("State/Province: \(administrativeArea)")
    }
    if let subAdministrativeArea = placemark.subAdministrativeArea {
        print("Sub-Administrative Area: \(subAdministrativeArea)")
    }
    if let postalCode = placemark.postalCode {
        print("Postal Code: \(postalCode)")
    }
    if let country = placemark.country {
        print("Country: \(country)")
    }
    if let isoCountryCode = placemark.isoCountryCode {
        print("ISO Country Code: \(isoCountryCode)")
    }
    if let timeZone = placemark.timeZone {
        print("Time Zone: \(timeZone)")
    }
    if let inlandWater = placemark.inlandWater {
        print("Inland Water: \(inlandWater)")
    }
    if let ocean = placemark.ocean {
        print("Ocean: \(ocean)")
    }
    if let areasOfInterest = placemark.areasOfInterest {
        print("Areas of Interest: \(areasOfInterest.joined(separator: ", "))")
    }
    if let location = placemark.location {
        print("Location Coordinates: \(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
    print("============================")
}
