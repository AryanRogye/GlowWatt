//
//  HapticStyle.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/5/25.
//

import UIKit

enum HapticStyle: String, CaseIterable {
    case none = "None"
    case subtle = "Subtle"
    case medium = "Medium"
    case strong = "Strong"
    
    private static var lastPlay: Date?
    private static let debounceInterval: TimeInterval = 0.3 // 300 ms between plays
    
    func playHaptic() {
        let now = Date()
        if let last = Self.lastPlay, now.timeIntervalSince(last) < Self.debounceInterval {
            return
        }
        Self.lastPlay = now
        
        switch self {
        case .none: break
        case .subtle:
            UISelectionFeedbackGenerator().selectionChanged()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .strong:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
