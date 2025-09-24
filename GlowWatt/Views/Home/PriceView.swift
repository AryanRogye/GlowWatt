//
//  PriceView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/23/25.
//

import SwiftUI

struct PriceView: View {
    
    @EnvironmentObject private var uiManager: UIManager
    @EnvironmentObject private var priceManager: PriceManager
    
    var body: some View {
        VStack {
            /// Get the price
            if let price = priceManager.price,
               /// Get the last updated date
               let last = priceManager.lastUpdated,
               /// Get the time left till next update
               let timeLeft = priceManager.timeLeftTillNextUpdate {
                /// View
                formattedPriceView(price, last, timeLeft)
            } else {
                /// Loading state
                Text("No data available yet. Check your internet connection.")
                    .font(.largeTitle)
                    .padding()
            }
        }
        .frame(minHeight: uiManager.priceHeight)
        .animation(.easeInOut(duration: 0.2), value: uiManager.priceHeight)
    }
    
    private func formattedPriceView(_ price: Double,
                                    _ last: Date,
                                    _ timeLeft: String) -> some View {
        VStack {
            Text("Current Price: \(price, specifier: "%.2f")¢")
                .font(.largeTitle)
            Text("Last Updated: \(last.formatted(date: .omitted, time: .shortened))")
            
            Text("Can refresh in:")
                .font(.headline)
                .padding(.top, 10)
            
            Text(timeLeft)
                .font(.system(.title2, design: .monospaced))
                .bold()
        }
    }
}
