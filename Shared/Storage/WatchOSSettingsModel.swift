//
//  WatchOSSettingsModel.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import Foundation

enum WidgetTapBehavior: String, CaseIterable {
    case refresh
    case open
}

@Observable @MainActor
final class WatchOSSettingsModel {
    private static let suite = UserDefaults(suiteName: "group.com.aryanrogye.glowwatt")!
    
    enum Keys {
        static let widgetTapBehavior = "widgetTapBehavior"
    }
    
    var widgetTapBehavior: WidgetTapBehavior {
        get {
            // Manually tell the system you are accessing this property
            access(keyPath: \.widgetTapBehavior)
            let raw = Self.suite.string(forKey: Keys.widgetTapBehavior)
            return WidgetTapBehavior(rawValue: raw ?? "") ?? .open
        }
        set {
            // Manually tell the system you are about to change this property
            withMutation(keyPath: \.widgetTapBehavior) {
                Self.suite.set(newValue.rawValue, forKey: Keys.widgetTapBehavior)
            }
        }
    }
}
