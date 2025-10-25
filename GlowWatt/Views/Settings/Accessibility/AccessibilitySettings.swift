//
//  AccessibilitySettings.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/25/25.
//

import SwiftUI

// MARK: - Haptic Setings
struct AccessibilitySettings: View {
    var body: some View {
        Section("Accessibility") {
            HapticSettings()
            PriceTapAnimation()
            PriceHeightSettings()
        }
    }
}
