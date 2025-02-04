//
//  File.swift
//  WeatherData
//
//  Created by 周源坤 on 2/3/25.
//

import AsyncLocationKit
import CoreLocation

public class AsyncLocationService {
    public nonisolated(unsafe) static let shared = AsyncLocationService()
    
    private let asyncLocationManager: AsyncLocationManager = {
        if Thread.current.isMainThread {
            AsyncLocationManager(desiredAccuracy: .bestAccuracy)
        } else {
            DispatchQueue.main.sync {
                AsyncLocationManager(desiredAccuracy: .bestAccuracy)
            }
        }
    }()
    
    public var authStatus: CLAuthorizationStatus {
        return asyncLocationManager.getAuthorizationStatus()
    }
    
    public func getCurrentLocation() async  -> Location? {
        do {
            let coordinate = try await asyncLocationManager.requestLocation()
            switch coordinate {
            case .didPaused:
                print("paused")
                return nil
            case .didResume:
                print("resumed")
                return nil
            case .didUpdateLocations(let locations):
                let geocoder = CLGeocoder()
                guard let lastSeenLocation = locations.last else {
                    print("Location Event success with no location")
                    return nil
                }
                guard let currentPlacemark = try await geocoder.reverseGeocodeLocation(lastSeenLocation).first else {
                    print("Reverse Geocode location failed")
                    return nil
                }
                let cityName = currentPlacemark.subLocality ?? currentPlacemark.locality ?? "Unknown"
                let stateName = currentPlacemark.administrativeArea ?? nil
                let countryName = currentPlacemark.country ?? "Unknown"
                let latitude = lastSeenLocation.coordinate.latitude
                let longitude = lastSeenLocation.coordinate.longitude
                return Location(name: cityName, localName: cityName, state: stateName, country: countryName, lat: latitude, lon: longitude, city: currentPlacemark.locality)
            case .didFailWith(let error):
                print("error: \(error.localizedDescription)")
                return nil
            case nil:
                print("Location Event is nil")
                return nil
            }
        } catch {
            print(error.localizedDescription, "\(#function)")
            return nil
        }
    }
   
    public func requestPermission() async -> CLAuthorizationStatus {
        return await self.asyncLocationManager.requestPermission(with: .always)
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
