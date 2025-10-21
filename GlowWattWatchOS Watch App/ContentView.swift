//
//  ContentView.swift
//  GlowWattWatchOS Watch App
//
//  Created by Aryan Rogye on 5/29/25.
//

import SwiftUI
import WidgetKit

extension Color {
    static let comfySystemGreen  = Color(red: 52/255,  green: 199/255, blue: 89/255)   // #34C759
    static let comfySystemRed    = Color(red: 255/255, green: 59/255,  blue: 48/255)   // #FF3B30
    static let comfySystemYellow = Color(red: 255/255, green: 204/255, blue: 0/255)    // #FFCC00
}

struct ContentView: View {
    
    @Environment(PriceProvider.self) var priceProvider
    
    // MARK: - Price Color
    var priceColor: Color {
        if let price = priceProvider.price {
            switch price {
            case ..<4:
                return .comfySystemGreen
            case 4..<8:
                return .comfySystemYellow
            default:
                return .comfySystemRed
            }
        }
        return .gray
    }
    
    // MARK: - Body
    var body: some View {
        @Bindable var priceProvider = priceProvider
        NavigationStack {
            ZStack {
                /// Background
                priceColor.ignoresSafeArea(.all)
                Button(action: {
                    WKInterfaceDevice.current().play(.success)
                    priceProvider.refresh()
                }) {
                    /// Price View
                    PriceView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { SettingsButton() }
            }
        }
        .containerBackground(priceColor, for: .navigation)
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onAppear {
            priceProvider.refresh()
        }
        .refreshable {
            priceProvider.refresh()
        }
    }
}

private struct SettingsButton: View {
    var body: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gear")
                .resizable()
                .frame(width: 20, height: 20)
                .padding(4)
        }
    }
}

#Preview {
    
    @Previewable @State var priceProvidier = PriceProvider()
    @Previewable @State var settingsModel = WatchOSSettingsModel()

    
    ContentView()
        .environment(priceProvidier)
        .environment(settingsModel)
}
