//
//  ContentView.swift
//  GlowWattWatchOS Watch App
//
//  Created by Aryan Rogye on 5/29/25.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @StateObject var priceProvider = PriceProvider.shared
    
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
        Button(action: {
            WKInterfaceDevice.current().play(.success)
            priceProvider.refresh()
        }) {
            ZStack {
                priceColor.ignoresSafeArea(.all)
                VStack {
                    Text("Tap To Refresh")
                        .foregroundStyle(.white)
                        .font(.system(size: 10, weight: .bold))
                        .padding(5)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    if let price = priceProvider.price, let last = priceProvider.lastUpdated {
                        /// Allow to wrap
                        Text("Current Price: \(price, specifier: "%.2f")¢")
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.black)
                            .font(.system(size: 35, weight: .bold))
                        /// Last updated date
                        Spacer()
                        Text(last.formatted())
                            .foregroundStyle(.white)
                            .font(.system(size: 20))
                    } else {
                        Text("Fetching price...")
                            .font(.largeTitle)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
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

class PriceProvider: ObservableObject {
    
    static let shared = PriceProvider()
    
    @Published var price: Double?
    @Published var lastUpdated: Date?
    @Published var timeLeftTillNextUpdate: String? = "2:00"
    
    private var timerStartDate: Date?

    /// Rate Limiting to Avoid excessive API calls 2 mins
    private var timer: Timer?

    func refresh() {
        /// Start the timer, if the timer is already running, invalidate
        if !isTimerRunning() {
            startTimer()
        } else {
            return
        }
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
    
    private func startTimer() {
        if !isTimerRunning() {
            timerStartDate = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: false) { [weak self] _ in
                self?.timer = nil
                self?.timerStartDate = nil
                self?.refresh()
            }
        }
    }
    
    private func isTimerRunning() -> Bool {
        guard let timer = timer, timer.isValid, let start = timerStartDate else {
            return false
        }

        let elapsed = Date().timeIntervalSince(start)
        let remaining = max(0, 120 - elapsed)

        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        DispatchQueue.main.async {
            self.timeLeftTillNextUpdate = String(format: "%d:%02d", minutes, seconds)
        }

        return true
    }
}

#Preview {
    ContentView()
}
