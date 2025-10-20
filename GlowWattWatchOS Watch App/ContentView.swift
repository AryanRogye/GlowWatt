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
        Button(action: {
            WKInterfaceDevice.current().play(.success)
            priceProvider.refresh()
        }) {
            ZStack {
                /// Background
                priceColor.ignoresSafeArea(.all)
                /// Price View
                PriceView()
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

#Preview {
    @Previewable @State var priceProvidier = PriceProvider()
    
    ContentView()
        .environment(priceProvidier)
}
