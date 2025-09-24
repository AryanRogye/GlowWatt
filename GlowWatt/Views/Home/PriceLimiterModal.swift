//
//  PriceLimiterModal.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/23/25.
//

import SwiftUI

struct PriceLimiterModal: View {
    
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var liveActivity : LiveActivitesManager
    @EnvironmentObject var uiManager    : UIManager
    
    /// Threshold represents the MAX Value the slider can be at, because we
    /// ONLY allow going under it for a set amount
    @State var threshold: Double = 0
    /// This is the value of the slider we are setting to
    @State var value : Double = 0
    
    var body: some View {
        VStack {
            if let price = priceManager.price {
                mainModal(price: price)
                    .onAppear {
                        threshold = price
                        value = price / 2
                    }
            } else {
                Text("No Data Available Yet.")
                    .font(.largeTitle)
            }
        }
    }
    
    @ViewBuilder
    private func mainModal(price: Double) -> some View {
        VStack {
            header(price: price)
            slider()
            startLiveActivity(price: price)
            Spacer()
        }
        .padding(.top, 32)
        .padding()
    }
    
    @ViewBuilder
    private func startLiveActivity(price: Double) -> some View {
        Button(action: {
            liveActivity.startSimpleLiveActivity()
            uiManager.activateLimiterModal = false
        }) {
            Text("Start Watcher")
                .foregroundStyle(Color(.white))
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBlue))
                }
        }
    }
    
    
    @ViewBuilder
    private func slider() -> some View {
        VStack(alignment: .center, spacing: 16) {
            Text("\(value, specifier: "%.2f")")
                .font(.largeTitle)
                .foregroundStyle(.primary)
                .monospacedDigit()

            Slider(
                value: $value,
                in: 0...threshold
            )
            .tint(.accentColor)
            .disabled(threshold <= 0)
            .accessibilityLabel("Price threshold")
            .accessibilityValue("\(value, specifier: "%.2f") cents")
            .sensoryFeedback(.selection, trigger: value) // optional subtle haptic on changes
            
            HStack {
                VStack(alignment: .center) {
                    Text("0.0")
                    Text("Min")
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("\(threshold, specifier: "%.2f")¢")
                    Text("Max")
                }
            }
        }
        .padding(.top, 32)
        .padding()
    }
    
    // MARK: - Header
    @ViewBuilder
    private func header(price: Double) -> some View {
        Text("Price Watcher: \(price, specifier: "%.2f")¢")
            .font(.largeTitle)
        
        Text("Set a threshold and start a Live Activity to keep an eye on ComEd prices. GlowWatt will update on your Lock Screen and Dynamic Island until the price falls below your limit or you stop watching.")
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
}


//#Preview {
//    @Previewable @StateObject var priceManager = PriceManager()
//    @Previewable @StateObject var liveActivity = LiveActivitesManager(onRefresh: {
//        Task {
//            await priceManager.refresh()
//        }
//    })
//    @Previewable @StateObject var uiManager    = UIManager()
//    
//    
//    PriceLimiterModal()
//        .environmentObject(priceManager)
//        .environmentObject(liveActivity)
//        .environmentObject(uiManager)
//        .task {
//            priceManager.price = 4.0
//        }
//}
