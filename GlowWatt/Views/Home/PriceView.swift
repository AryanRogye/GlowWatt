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
            if let price = priceManager.price {
                formattedPriceView(price)
                
                if let last = priceManager.lastUpdated {
                    formattedLastUpdatedView(last)
                }
                   /// Get the time left till next update
                if let timeLeft = priceManager.timeLeftTillNextUpdate {
                    formattedTimeLeftTillNextUpdate(timeLeft)
                }
                if priceManager.readyToUpdate {
                    Text("Tap The Screen To Refresh")
                        .font(.largeTitle)
                        .padding()
                }
            } else {
                Text("No data available yet. Please Reload.")
                    .font(.largeTitle)
                    .padding()
            }
        }
        .frame(minHeight: uiManager.priceHeight)
        .animation(.easeInOut(duration: 0.2), value: uiManager.priceHeight)
    }
    
    private func formattedPriceView(_ price: Double) -> some View {
        Text("Current Price: \(price, specifier: "%.2f")¢")
            .font(.largeTitle)
            .contentTransition(.numericText())
            .animation(.snappy(duration: 0.25), value: price)
    }
    
    private func formattedLastUpdatedView(
        _ last: Date
    ) -> some View {
        Text("Last Updated: \(last.formatted(date: .omitted, time: .shortened))")
            .contentTransition(.numericText())
            .animation(.snappy(duration: 0.25), value: last)
    }
    
    private func formattedTimeLeftTillNextUpdate(
        _ timeLeft: String
    ) -> some View {
        VStack {
            Text("Can refresh in:")
                .font(.headline)
                .padding(.top, 10)
            
            Text(timeLeft)
                .font(.system(.title2, design: .monospaced))
                .bold()
                .contentTransition(.numericText())
                .animation(.snappy(duration: 0.25), value: priceManager.secondsLeft)
        }
    }
}
