//
//  Home.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI

struct Home: View {
    
    @EnvironmentObject var priceProvider : PriceProvider
    @EnvironmentObject var uiManager: UIManager
    
    var priceColor: Color {
        if let price = priceProvider.price {
            switch price {
            case ..<4:
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
        ScrollView {
            priceView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        // MARK: - View Modifiers
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                priceProvider.refresh()
            }
        }
        .onTapGesture {
            priceProvider.refresh()
        }
        .refreshable {
            priceProvider.refresh()
        }
        .background {
            priceColor.ignoresSafeArea(.all)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                NavigationLink(destination: Settings()) {
                    Circle()
                        .fill(Color.clear)
                        .overlay {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(Color.primary)
                                .font(.system(size: 20, weight: .bold))
                        }
                }
                .padding(.leading)
            }
        }
        .sheet(isPresented: $uiManager.activatePriceHeightModal) {
            PriceHeightModal()
                .presentationDetents([.fraction(0.2)])
                .presentationDragIndicator(.hidden)
        }
    }
    
    private var priceView: some View {
        VStack {
            /// Get the price
            if let price = priceProvider.price,
               /// Get the last updated date
               let last = priceProvider.lastUpdated,
               /// Get the time left till next update
               let timeLeft = priceProvider.timeLeftTillNextUpdate {
                /// View
                formattedPriceView(price, last, timeLeft)
            } else {
                /// Loading state
                Text("Fetching price...")
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
