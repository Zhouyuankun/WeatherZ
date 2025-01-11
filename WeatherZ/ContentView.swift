//
//  ContentView.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/5/25.
//

import SwiftUI
import CoreLocation


var location: CLLocation?

struct ContentView: View {
    @State var locationViewModel = LocationViewModel()
    
    var body: some View {
        switch locationViewModel.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            RequestLocationView()
                .environment(locationViewModel)
        case .authorizedAlways, .authorizedWhenInUse:
            MultiCityView()
                .environment(locationViewModel)
        default:
            Text("Unexpected status")
        }
    }
}

struct RequestLocationView: View {
    @Environment(LocationViewModel.self) var locationViewModel
    var body: some View {
        VStack {
            Image(systemName: "location.circle")
                .resizable()
                .frame(width: 100, height: 100, alignment: .center)
                .foregroundColor(.blue)
            Button(action: {
                locationViewModel.checkPermission()
            }, label: {
                Label("Allow tracking", systemImage: "location")
            })
            .padding(10)
            .foregroundColor(.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            Text("We need location to present weather")
                .foregroundColor(.gray)
                .font(.caption)
        }
    }
}

struct ErrorView: View {
    var errorText: String
    
    var body: some View {
        VStack {
            Image(systemName: "xmark.octagon")
                    .resizable()
                .frame(width: 100, height: 100, alignment: .center)
            Text(errorText)
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.red)
    }
}

struct PairView: View {
    
    let leftText: String
    let rightText: String
    
    var body: some View {
        HStack {
            Text(leftText)
            Spacer()
            Text(rightText)
        }
    }
}

#Preview {
    ContentView()
}
