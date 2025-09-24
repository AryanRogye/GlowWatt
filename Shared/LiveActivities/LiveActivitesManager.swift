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
    
    @Published var lastUpdated: Date?
    @Published var price : Double?
    
    @Published var hasStarted = false
    private var activity: Activity<GlowWattAttributes>?
    
    var onRefresh: () async -> (Double?, Date?)
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(onRefresh: @escaping () async -> (Double?, Date?)) {
        self.onRefresh = onRefresh
        
        $hasStarted
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
    
//    public func bind(to priceManager: PriceManager) {
//        priceManager.$price
//            .sink { [weak self] price in
//                guard let self = self else { return }
//                self.price = price
//            }
//            .store(in: &cancellables)
//    }
    
    
    private var refreshTimer: Timer?
    
    private func startRefreshTimer() {
        guard hasStarted else { return }
        refreshTimer?.invalidate()
        /// Every 5 Mins
        refreshTimer =  Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.updateLiveActivity), userInfo: nil, repeats: true)
    }
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
    }
    
    
    @objc func updateLiveActivity() {
        if hasStarted {
            Task {
                (self.price, self.lastUpdated) = await onRefresh()
                startSimpleLiveActivity()
            }
        }
    }
    
    func startSimpleLiveActivity() {
        Task {
            (self.price, self.lastUpdated) = await onRefresh()
            startSimpleLiveActivity()
        }
        guard let lastUpdated = lastUpdated else { return }
        guard let price = price else { return }
        let attributes = GlowWattAttributes(name: "Aryan")
        
        let contentState = GlowWattAttributes.ContentState(
            lastUpdated: lastUpdated,
            price: price
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
                    state: GlowWattAttributes.ContentState(lastUpdated: .now, price: 0),
                    staleDate: nil
                )
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
        }
        activity = nil
        hasStarted = false
    }
}

