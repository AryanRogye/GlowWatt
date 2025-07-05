//
//  HistoryView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/5/25.
//

import SwiftUI

public enum HistoryViewState {
    case currentHistory
    case historyCount
}

struct HistoryView: View {
    
    let state: HistoryViewState
    
    init(for state: HistoryViewState) {
        self.state = state
    }
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var userPriceManager = UserPricesManager.shared
    @State private var tempPriceMax: Int = 0
    
    var body: some View {
        VStack {
            switch state {
            case .currentHistory:
                currentHistoryView
            case .historyCount:
                historyCountView
            }
            Spacer()
        }
        .padding()
        .onAppear {
            // Load the current prices if needed
            tempPriceMax = userPriceManager.maxPricesHistory
        }
    }
    
    private var currentHistoryView: some View {
        VStack {
            HStack {
                Text("Max Count:")
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(userPriceManager.maxPricesHistory)")
                    .foregroundColor(.secondary)
            }
            List {
                ForEach(userPriceManager.prices) { price in
                    HStack {
                        Text("\(price.price, specifier: "%.2f")¢")
                            .font(.largeTitle)
                        Spacer()
                        Text(price.date.formatted())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete { indexSet in
                    userPriceManager.deletePrices(at: indexSet)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Current History")
    }
    
    private var historyCountView: some View {
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
    }
}
