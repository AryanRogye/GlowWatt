//
//  ContentView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @StateObject var priceProvider = PriceProvider.shared
    
    var priceColor: Color {
        if let price = priceProvider.price {
            switch price {
            case 0..<4:
                return .green
            case 4..<8:
                return .yellow
            default:
                return .red
            }
        }
        return .gray
    }
    
    var body: some View {
        ZStack {
            priceColor.ignoresSafeArea(.all)
            ScrollView {
                VStack {
                    if let price = priceProvider.price, let last = priceProvider.lastUpdated {
                        Text("Current Price: $\(price, specifier: "%.2f")")
                            .font(.largeTitle)
                        Text(last.formatted())
                    } else {
                        Text("Fetching price...")
                            .font(.largeTitle)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 500)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            priceProvider.refresh()
        }
        .onAppear {
            priceProvider.refresh()
        }
        .refreshable {
            priceProvider.refresh()
        }
    }
}

class PriceProvider: ObservableObject {
    
    static let shared = PriceProvider()
    
    @Published var price: Double?
    @Published var lastUpdated: Date?

    func refresh() {
        Task {
            let fetchedPrice = await API.fetchComEdPrice()
            
            AppStorage.setPrice(fetchedPrice ?? 0.0)
            AppStorage.setLastUpdated()
            
            if let price = AppStorage.getPrice() {
                self.price = price
            } else {
                self.price = nil
            }
            if let lastUpdated = AppStorage.getLastUpdated() {
                self.lastUpdated = lastUpdated
            } else {
                self.lastUpdated = nil
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    ContentView()
}
