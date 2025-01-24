//
//  SettingView.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/23/25.
//
import SwiftUI

struct SettingView: View {
    @Environment(\.modelContext) private var context
    
    @State var showAlert = false
    var body: some View {
        List {
            Section {
                Button(role: .destructive, action: {
                    showAlert = true
                }, label: {
                    Text("Delete all saved locations")
                })
            }
        }
        .alert("Confirm delete all saved locations", isPresented: $showAlert) {
            Button(role: .cancel, action: {}, label: {Text("Cancel")})
            Button(role: .destructive, action: {
                try! context.delete(model: SubscribedLocation.self)
            }, label: {
                Text("Delete")
            })
        }
    }
}
