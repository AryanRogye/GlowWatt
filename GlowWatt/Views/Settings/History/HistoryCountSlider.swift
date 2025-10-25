//
//  HistoryCountSlider.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/18/25.
//

import SwiftUI

struct HistoryCountSlider: View {
    
    @ObservedObject private var userPriceManager = UserPricesManager.shared
    
    @State private var tempPriceMax: Int = 0
    @State private var shouldShowReset = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Save") {
                    if tempPriceMax != userPriceManager.maxPricesHistory {
                        userPriceManager.setMaxPricesHistory(tempPriceMax)
                    }
                }
            }
            
            // Add your history count content here
            Slider(
                value: Binding(
                    get: { Double(tempPriceMax) },
                    set: {
                        tempPriceMax = Int($0)
                    }
                ),
                in: 10...500,
                step: 1
            )
            Spacer()
        }
        .navigationTitle("History Count \(tempPriceMax)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    shouldShowReset = true
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.primary)
                }
            }
        }
        .onAppear {
            // Load the current prices if needed
            tempPriceMax = userPriceManager.maxPricesHistory
        }
        .alert("Reset Max History", isPresented: $shouldShowReset) {
            Button("Cancel", role: .cancel) {
                shouldShowReset = false
            }
            
            Button("Reset", role: .destructive) {
                userPriceManager.resetMaxPriceHistory()
                tempPriceMax = userPriceManager.maxPricesHistory
            }
            
        } message: {
        }
    }
}
