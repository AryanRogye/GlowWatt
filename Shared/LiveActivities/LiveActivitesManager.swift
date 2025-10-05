//
//  LiveActivitesManager.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/23/25.
//

import ActivityKit
import Combine
import Foundation

/// We Make it ObservableObject, so SwiftUI can start it easier
@MainActor
final class LiveActivitesManager: ObservableObject {
    
    /// Flag if we started Live Activities or not
    @Published var hasStarted = false
    
    private var cancellables: Set<AnyCancellable> = []

    /// Past Prices, which start AFTER, the first start, till the end, where it should get reset
    private var pastPrices: [Double] = []
    
    /// Activity We Send
    private var activity: Activity<GlowWattAttributes>?
    
    /// What to do onRefresh
    var onRefresh: () async -> (Double?, Date?)
    
    private var refreshTimer: Timer?

    
    init(onRefresh: @escaping () async -> (Double?, Date?)) {
        self.onRefresh = onRefresh
        
        $hasStarted
            .removeDuplicates()
            .sink { [weak self] started in
                guard let self = self else { return }
                if started {
                    self.startRefreshTimer()
                } else {
                    self.stopRefreshTimer()
                }
            }
            .store(in: &cancellables)
    }
    
    public func start() {
        hasStarted = true
        updateLiveActivity()
    }
    
    @objc private func updateLiveActivity() {
        if hasStarted {
            Task {
                let (p, u) = await onRefresh()
                startSimpleLiveActivity(by: "update", price: p, lastUpdated: u)
            }
        }
    }
    
    private func startSimpleLiveActivity(by: String, price: Double?, lastUpdated: Date?) {
        guard let lastUpdated = lastUpdated else { return }
        guard let price = price else { return }
        let attributes = GlowWattAttributes(name: "Aryan")
        
        pastPrices.append(price)
        let contentState = GlowWattAttributes.ContentState(
            lastUpdated: lastUpdated,
            price: price,
            pastPrices: pastPrices
        )
        
        /// Construct What i'm gonna send to the Live Activity
        let content = ActivityContent(state: contentState, staleDate: nil)
        
        /// If Started then we update it
        if let existingActivity = activity {
            Task {
                await existingActivity.update(content)
                hasStarted = true
            }
        }
        
        /// If not started then we start it
        else {
            do {
                activity = try Activity<GlowWattAttributes>.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
                print("✅ Live Activity started")
                hasStarted = true
            } catch {
                print("❌ Failed to start Live Activity: \(error)")
                hasStarted = false
            }
        }
    }
    
    /// Function to Stop the Live Activity
    func stopLiveActivity() {
        Task {
            for activity in Activity<GlowWattAttributes>.activities {
                let finalContent = ActivityContent(
                    state: GlowWattAttributes.ContentState(lastUpdated: .now, price: 0, pastPrices: []),
                    staleDate: nil
                )
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
            activity = nil
            hasStarted = false
            pastPrices.removeAll()
        }
    }
}

// MARK: - Timers
extension LiveActivitesManager {
    private func startRefreshTimer() {
        guard hasStarted else { return }
        refreshTimer?.invalidate()
        /// Every 5 Mins
        refreshTimer =  Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.updateLiveActivity), userInfo: nil, repeats: true)
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
    }
}
