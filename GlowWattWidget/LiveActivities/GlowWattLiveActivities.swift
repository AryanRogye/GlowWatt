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
            GlowWattLockScreen(context: context)

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
            DynamicIslandExpandedRegion(.bottom) {
                Text(context.state.lastUpdated.description)
            }
        } compactLeading: {
            
        } compactTrailing: {
            
        } minimal: {
            
        }
    }
}

struct GlowWattLockScreen: View {
    
    var priceColor: Color {
        switch context.state.price {
        case ..<4:
            return .green
        case 4..<8:
            return .yellow
        default:
            return .red
        }
    }

    var context : ActivityViewContext<GlowWattAttributes>
    
    var body: some View {
        ZStack {
            priceColor.ignoresSafeArea()
            
            VStack {
                HStack {
                    Text("\(context.state.price, specifier: "%.2f")¢")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 2)
                        .widgetAccentable()
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
