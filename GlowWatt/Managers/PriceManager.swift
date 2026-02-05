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
    @Published var readyToUpdate : Bool = false
    
    private var timerStartDate: Date?
    private var timerEndDate: Date?
    
    /// Rate Limiting to Avoid excessive API calls 2 mins
    private var uiUpdateTimer: Timer?
    
    private var isRefreshing: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    var onHaptic: (() -> Void)?
    
    init() {
        price = AppStorage.getPrice()
        self.lastUpdated = AppStorage.getLastUpdated()
        
        loadComEdPriceOption()
        observeComEdPriceOption()
    }
    
    @MainActor
    deinit { uiUpdateTimer?.invalidate() }
    
    #if DEBUG
    let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    #endif
    
    @discardableResult
    func refresh() async -> (Double?, Date?) {
        
        #if DEBUG
        if isPreview {
            /// Pick Random Number Between 4 - 10
            let double = Double.random(in: 4.0...10.0)
            price = double
            return (double, .now)
        }
        #endif
        
        /// Haptic Feedback
        onHaptic?()
        readyToUpdate = false
        
        if isRefreshing { return (price, lastUpdated) }
        isRefreshing = true
        defer { isRefreshing = false }
        
        /// Start the timer, if the timer is already running, invalidate
        if isTimerRunning() {
            return (price, lastUpdated)
        }
        
        /// Get the fetched price
        let fetchedPrice = await API.fetchComEdPrice(option: comEdPriceOption)
        
        /// Save Price if not nil and > 0
        if let price = fetchedPrice {
            startTimer()
            
            self.price = price

            /// Store it in the settings
            AppStorage.setPrice(price)
            AppStorage.setLastUpdated()
            
            /// Set Last Updated
            self.lastUpdated = AppStorage.getLastUpdated()
            UserPricesManager.shared.addStorage(for: price)
        }
        
        
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
        readyToUpdate = false
    }
    
    func updateCountdownString() {
        guard let end = timerEndDate else { return }
        let remaining = max(0, Int(ceil(end.timeIntervalSinceNow)))
        secondsLeft = remaining
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        timeLeftTillNextUpdate = formatter.string(from: TimeInterval(remaining)) ?? "0:00"
        
        if remaining <= 0 {
            finishTimer()
        }
    }
    
    func finishTimer() {
        uiUpdateTimer?.invalidate()
        uiUpdateTimer = nil
        timerStartDate = nil
        timerEndDate = nil
        
        readyToUpdate = true
        
        secondsLeft = 0
        timeLeftTillNextUpdate = "0:00"
    }
}


// MARK: - ComEd Price Option Persistence
extension PriceManager {
    private static let comEdPriceOptionKey = "comEdPriceOption"
    
    public func resetComEdPriceOption() {
        self.comEdPriceOption = .instantHourlyPrice
    }
    
    /// Load saved option from persistent storage on init
    fileprivate func loadComEdPriceOption() {
        if let raw = UserDefaults.standard.string(forKey: Self.comEdPriceOptionKey),
           let saved = ComdEdPriceOption(rawValue: raw) {
            comEdPriceOption = saved
        }
    }
    
    /// Observe changes and persist automatically
    fileprivate func observeComEdPriceOption() {
        $comEdPriceOption
            .dropFirst()
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
