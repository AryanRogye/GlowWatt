//
//  PriceProvider.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI
import WidgetKit

@MainActor
class PriceProvider: ObservableObject {
    
    @Published var price: Double?
    @Published var lastUpdated: Date?
    @Published var timeLeftTillNextUpdate: String? = "2:00"
    
    private var timerStartDate: Date?
    
    /// Rate Limiting to Avoid excessive API calls 2 mins
    private var timer: Timer?
    
    private var isRefreshing: Bool = false
    
    func refresh() {
        
        if isRefreshing { return }
        
        Task {
            isRefreshing = true
            defer { isRefreshing = false }
            
            /// Start the timer, if the timer is already running, invalidate
            if !isTimerRunning() {
                startTimer()
            } else {
                return
            }

            let fetchedPrice = await API.fetchComEdPrice()
            
            AppStorage.setPrice(fetchedPrice ?? 0.0)
            AppStorage.setLastUpdated()
            
            if let price = AppStorage.getPrice() {
                DispatchQueue.main.async {
                    self.price = price
                }
            } else {
                self.price = nil
            }
            if let lastUpdated = AppStorage.getLastUpdated() {
                DispatchQueue.main.async {
                    self.lastUpdated = lastUpdated
                }
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
                DispatchQueue.main.async {
                    self?.timer = nil
                    self?.timerStartDate = nil
                    self?.refresh()
                }
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
