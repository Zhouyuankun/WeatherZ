//
//  LocationService.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/6/25.
//

import Foundation
import CoreLocation
import Combine

public class LocationService: NSObject, CLLocationManagerDelegate {
    public nonisolated(unsafe) static let shared = LocationService()
    
    private let locationManager: CLLocationManager
    
    public var currentPlacemark: CLPlacemark?
    
    public var locationPub = PassthroughSubject<CLLocation, Never>()
    public var authPub = PassthroughSubject<CLAuthorizationStatus, Never>()
    public var localLocationPub = PassthroughSubject<Location, Never>()
    
    public override init() {
        locationManager = CLLocationManager()
        authPub.send(locationManager.authorizationStatus)
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    public func updateLoc() {
        locationManager.startUpdatingLocation()
    }
    
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authPub.send(manager.authorizationStatus)
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            updateLoc()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastSeenLocation = locations.first!
        locationPub.send(lastSeenLocation)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(lastSeenLocation) { (placemarks, error) in
            self.currentPlacemark = placemarks?.first
        }
        if let currentPlacemark = currentPlacemark {
            let cityName = currentPlacemark.subLocality ?? currentPlacemark.locality ?? "Unknown"
            let stateName = currentPlacemark.administrativeArea ?? nil
            let countryName = currentPlacemark.country ?? "Unknown"
            let latitude = lastSeenLocation.coordinate.latitude
            let longitude = lastSeenLocation.coordinate.longitude
            localLocationPub.send(Location(name: cityName, localName: cityName, state: stateName, country: countryName, lat: latitude, lon: longitude, city: currentPlacemark.locality))
            manager.stopUpdatingLocation()
        }
    }
    
    public func getCityLocationInfo(cityName: String) async -> Result<[GeoAPIResponse], Error> {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(cityName)
            
            let filteredResponses = placemarks.compactMap { placemark -> GeoAPIResponse? in
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
public func printPlacemarkDetails(_ placemark: CLPlacemark) {
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
