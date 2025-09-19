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
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Save") {
                    if tempPriceMax != userPriceManager.maxPricesHistory {
                        userPriceManager.setMaxPricesHistory(tempPriceMax)
                    }
                    dismiss()
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
        .onAppear {
            // Load the current prices if needed
            tempPriceMax = userPriceManager.maxPricesHistory
        }
    }
}
