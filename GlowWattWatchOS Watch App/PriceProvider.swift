//
//  PriceProvider.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import Foundation
import WidgetKit

@Observable @MainActor
class PriceProvider {
    var price: Double?
    var lastUpdated: Date?
    var timeLeftTillNextUpdate: String? = "2:00"
    
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
            
            if let price = fetchedPrice {
                DispatchQueue.main.async {
                    self.price = price
                }
            } else {
                DispatchQueue.main.async {
                    self.price = nil
                }
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


