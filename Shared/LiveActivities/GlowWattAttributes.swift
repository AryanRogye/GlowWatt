//
//  GlowWattAttributes.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/23/25.
//

import WidgetKit
import ActivityKit

struct GlowWattAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        var lastUpdated: Date
        var price: Double
    }
    
    /// State Info Not Shown
    var name: String  // Static info, not shown in UI
}
