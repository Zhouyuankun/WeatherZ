//
//  SubscribedCity.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/11/25.
//

import Foundation
import SwiftData


@Model
public final class SubscribedCity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var localName: String
    public var state: String?
    public var country: String
    public var lat: Double
    public var lon: Double
    
    init(name: String, localName: String, state: String? = nil, country: String, lat: Double, lon: Double) {
        self.id = UUID()
        self.name = name
        self.localName = localName
        self.state = state
        self.country = country
        self.lat = lat
        self.lon = lon
    }
}

struct City: Hashable {
    let name: String
    let localName: String
    let state: String?
    let country: String
    let lat: Double
    let lon: Double
}

extension SubscribedCity {
    var city: City {
        return City(name: self.name, localName: self.localName, state: self.state, country: self.country, lat: self.lat, lon: self.lon)
    }
}
