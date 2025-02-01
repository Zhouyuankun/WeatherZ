//
//  File.swift
//  WeatherUI
//
//  Created by 周源坤 on 1/27/25.
//

import SwiftUI
import WeatherData
import SwiftData

public struct SearchResultCell: View {
    public let geoInfo: GeoAPIResponse
    @Environment(\.modelContext) private var context
    @Query var subscribedLocations: [SubscribedLocation]
    
    public init(geoInfo: GeoAPIResponse) {
        self.geoInfo = geoInfo
    }
    
    var foundInSubscription: Bool {
        for location in subscribedLocations {
            if location.name == geoInfo.localeName && location.city == geoInfo.city && location.state == geoInfo.state && location.country == geoInfo.country {
                return true
            }
        }
        return false
    }
    
    public var body: some View {
        
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Location: \(geoInfo.localeName)")
                    if let city = geoInfo.city {
                        Text("City: \(city)")
                    }
                    if let state = geoInfo.state {
                        Text("Province: \(state)")
                    }
                    Text("Region: \(geoInfo.country)")
                }
                Spacer()
                Button(action: {
                    let location = SubscribedLocation(name: geoInfo.name, localName: geoInfo.localeName, city: geoInfo.city, state: geoInfo.state, country: geoInfo.country, lat: geoInfo.lat, lon: geoInfo.lon)
                    context.insert(location)
                }, label: {
                    Text("Subscribe")
                        .foregroundStyle(.white)
                        .padding()
                        .background(foundInSubscription ? .gray : .blue)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                })
                .buttonStyle(.borderless)
                .disabled(foundInSubscription)
            }
        }
    }
}
