//
//  GlowWattLiveActivities.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/23/25.
//
import WidgetKit
import SwiftUI

struct GlowWattLiveActivities: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GlowWattAttributes.self) { context in
            
            // Lock screen UI
            GlowWattLockScreen()

        } dynamicIsland: { context in
            
            /// Dynamic Island UI
            GlowWattDynamicIsland(context)
        }
    }
    
    private func GlowWattDynamicIsland(_ context: ActivityViewContext<GlowWattAttributes>) -> DynamicIsland {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
            }
            DynamicIslandExpandedRegion(.trailing) {
            }
            DynamicIslandExpandedRegion(.center) {
                Text("\(context.state.price, specifier: "%.2f")")
            }
        } compactLeading: {
            
        } compactTrailing: {
            
        } minimal: {
            
        }
    }
}

struct GlowWattLockScreen: View {
    var body: some View {
        
    }
}
