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
    private var activityID: String?
    
    func startSimpleLiveActivity(with price: Double) {
        let attributes = GlowWattAttributes(name: "Aryan")
        
        let content = ActivityContent(
            state: GlowWattAttributes.ContentState(price: price),
            staleDate: nil
        )
        
        Task.detached {
            let activities = Activity<GlowWattAttributes>.activities
            
            if let activityID = await MainActor.run(body: { self.activityID }),
               let index = activities.firstIndex(where: { $0.id == activityID }) {
                
                await activities[index].update(content)
                
                await MainActor.run {
                    self.hasStarted = true
                }
            } else {
                do {
                    let newActivity = try Activity<GlowWattAttributes>.request(
                        attributes: attributes,
                        content: content,
                        pushType: nil
                    )
                    
                    await MainActor.run {
                        self.activityID = newActivity.id
                        self.hasStarted = true
                    }
                } catch {
                    await MainActor.run {
                        self.hasStarted = false
                    }
                }
            }
        }
    }
    
    /// Function to Stop the Live Activity
    func stopLiveActivity() {
        Task.detached {
            for activity in Activity<GlowWattAttributes>.activities {
                let finalContent = ActivityContent(
                    state: GlowWattAttributes.ContentState(price: 0),
                    staleDate: nil
                )
                
                await activity.end(finalContent, dismissalPolicy: .immediate)
            }
            
            await MainActor.run {
                self.activityID = nil
                self.hasStarted = false
            }
        }
    }
}
