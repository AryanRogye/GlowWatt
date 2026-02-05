//
//  LiveActivitesManager.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/23/25.
//

import ActivityKit
import Combine

/// We Make it ObservableObject, so SwiftUI can start it easier
@MainActor
final class LiveActivitesManager: ObservableObject {
    
    @Published var hasStarted = false
    private var activity: Activity<GlowWattAttributes>?
    
    func startSimpleLiveActivity(with price: Double) {
        print("Starting Live Activities")
        let attributes = GlowWattAttributes(name: "Aryan")
        
        let contentState = GlowWattAttributes.ContentState(
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
                    state: GlowWattAttributes.ContentState(price: 0),
                    staleDate: nil
                )
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
        }
        activity = nil
        hasStarted = false
    }
}
