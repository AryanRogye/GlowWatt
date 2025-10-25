//
//  AccessibilitySettings.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/25/25.
//

import SwiftUI

// MARK: - Haptic Setings
struct AccessibilitySettings: View {
    
    @EnvironmentObject var uiManager: UIManager
    var body: some View {
        
        Section("Accessibility") {
            List {
                Picker("Strength", selection: $uiManager.hapticStyle) {
                    ForEach(HapticStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .onChange(of: uiManager.hapticStyle) { _, value in
                    uiManager.saveHapticPreference()
                }
            }
            PriceTapAnimation()
            PriceHeightSettings()
        }
    }
}
