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
    @Published var secondsLeft: Int? = 120
    
    @Published var comEdPriceOption : ComdEdPriceOption = .instantHourlyPrice
    
    private var timerStartDate: Date?
    private var timerEndDate: Date?
    
    /// Rate Limiting to Avoid excessive API calls 2 mins
    private var uiUpdateTimer: Timer?
    
    private var isRefreshing: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    var onHaptic: (() -> Void)?
    
    init() {
        loadComEdPriceOption()
        observeComEdPriceOption()
    }
    
    @discardableResult
    func refresh() async -> (Double?, Date?) {
        
        /// Haptic Feedback
        onHaptic?()
        
        if isRefreshing { return (price, lastUpdated) }
        isRefreshing = true
        defer { isRefreshing = false }
        
        /// Start the timer, if the timer is already running, invalidate
        if isTimerRunning() {
            return (price, lastUpdated)
        }
        
        /// Get the fetched price
        let fetchedPrice = await API.fetchComEdPrice(option: comEdPriceOption)
        
        if fetchedPrice != nil {
            startTimer()
        }
        
        /// Store it in the settings
        AppStorage.setPrice(fetchedPrice ?? 0.0)
        AppStorage.setLastUpdated()
        
        /// Set Price
        self.price = fetchedPrice
        
        /// Save Price if not nil and > 0
        if let price = price, price > 0 {
            UserPricesManager.shared.addStorage(for: price)
        }
        
        /// Set Last Updated
        self.lastUpdated = AppStorage.getLastUpdated()
        
        WidgetCenter.shared.reloadAllTimelines()
        
        return (price, lastUpdated)
    }
}


// MARK: - Rate Limit Timer Management
private extension PriceManager {
    func startTimer() {
        resetRateLimitTimer()
        
        let start = Date()
        timerStartDate = start
        timerEndDate = start.addingTimeInterval(120)
        
        uiUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateCountdownString()
            }
        }
        
        if let u = uiUpdateTimer {
            RunLoop.main.add(u, forMode: .common)
        }
        
        updateCountdownString()
    }
    
    func isTimerRunning() -> Bool {
        guard let end = timerEndDate else { return false }
        return end.timeIntervalSinceNow > 0
    }
    
    /// Cancel the current rate-limit timer so the next refresh can proceed immediately
    func resetRateLimitTimer() {
        uiUpdateTimer?.invalidate()
        uiUpdateTimer = nil
        timerStartDate = nil
        timerEndDate = nil
        secondsLeft = nil
        timeLeftTillNextUpdate = nil
    }
    
    func updateCountdownString() {
        guard let end = timerEndDate else { return }
        let remaining = max(0, Int(end.timeIntervalSinceNow.rounded()))
        secondsLeft = remaining
        
        let m = remaining / 60
        let s = remaining % 60
        timeLeftTillNextUpdate = String(format: "%d:%02d", m, s)
        
        if remaining == 0 {
            resetRateLimitTimer()
        }
    }
}


// MARK: - ComEd Price Option Persistence
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
