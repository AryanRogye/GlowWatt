//
//  PriceManager.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI
import WidgetKit
import Combine

@MainActor
class PriceManager: ObservableObject {
    
    @Published var price: Double?
    @Published var lastUpdated: Date?
    @Published var timeLeftTillNextUpdate: String? = "2:00"
    @Published var comEdPriceOption : ComdEdPriceOption = .instantHourlyPrice
    
    private var timerStartDate: Date?
    
    /// Rate Limiting to Avoid excessive API calls 2 mins
    private var timer: Timer?
    
    private var isRefreshing: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadComEdPriceOption()
        observeComEdPriceOption()
    }
    
    @discardableResult
    func refresh() async -> (Double?, Date?) {
        
        if isRefreshing { return (price, lastUpdated) }
        isRefreshing = true
        defer { isRefreshing = false }
        
        /// Start the timer, if the timer is already running, invalidate
        if !isTimerRunning() {
            startTimer()
        } else {
            return (price, lastUpdated)
        }
        
        /// Get the fetched price
        let fetchedPrice = await API.fetchComEdPrice(option: comEdPriceOption)
        
        /// Store it in the settings
        AppStorage.setPrice(fetchedPrice ?? 0.0)
        AppStorage.setLastUpdated()
        
        if let price = fetchedPrice {
            DispatchQueue.main.async {
                self.price = price
                UserPricesManager.shared.addStorage(for: price)
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
        
        return (price, lastUpdated)
    }
    
    private func startTimer() {
        if !isTimerRunning() {
            timerStartDate = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 120, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.timer = nil
                    self?.timerStartDate = nil
                    Task {
                        await self?.refresh()
                    }
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
    
    /// Cancel the current rate-limit timer so the next refresh can proceed immediately
    private func resetRateLimitTimer() {
        timer?.invalidate()
        timer = nil
        timerStartDate = nil
    }
}

extension PriceManager {
    private static let comEdPriceOptionKey = "comEdPriceOption"
    
    /// Load saved option from persistent storage on init
    fileprivate func loadComEdPriceOption() {
        if let raw = UserDefaults.standard.string(forKey: Self.comEdPriceOptionKey),
           let saved = ComdEdPriceOption(rawValue: raw) {
            self.comEdPriceOption = saved
        }
    }
    
    /// Observe changes and persist automatically
    fileprivate func observeComEdPriceOption() {
        $comEdPriceOption
            .removeDuplicates()
            .sink { [weak self] option in
                guard let self = self else { return }
                UserDefaults.standard.set(option.rawValue, forKey: Self.comEdPriceOptionKey)
                self.resetRateLimitTimer()
                Task {
                    await self.refresh()
                }
            }
            .store(in: &cancellables)
    }
}

