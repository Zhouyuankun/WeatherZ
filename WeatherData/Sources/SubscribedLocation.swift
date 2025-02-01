//
//  SubscribedCity.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/11/25.
//

import Foundation
import SwiftData


@Model
public final class SubscribedLocation {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var localName: String
    public var city: String?
    public var state: String?
    public var country: String
    public var lat: Double
    public var lon: Double
    
    public init(name: String, localName: String, city: String? = nil, state: String? = nil, country: String, lat: Double, lon: Double) {
        self.id = UUID()
        self.name = name
        self.localName = localName
        self.city = city
        self.state = state
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}

public struct Location: Hashable {
    public let name: String
    public let localName: String
    public let state: String? //for province
    public let country: String
    public let lat: Double
    public let lon: Double
    
    //addtional
    public let city: String?
}

public extension SubscribedLocation {
    var location: Location {
        return Location(name: self.name, localName: self.localName, state: self.state, country: self.country, lat: self.lat, lon: self.lon, city: self.city)
    }
}

public extension Location {
    var belongInfo: String {
        var belongs: [String] = []
        if let city = self.city {
            belongs.append(city)
        }
        if let state = self.state {
            belongs.append(state)
        }
        belongs.append(self.country)
        return belongs.joined(separator: "-")
    }
}
