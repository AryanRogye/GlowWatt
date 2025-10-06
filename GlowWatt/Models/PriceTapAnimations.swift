//
//  PriceTapAnimations.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/6/25.
//

import Foundation

enum PriceTapAnimations: String, CaseIterable {
    case none = "None"
    case ripple = "Ripple"
    
    var icon: String {
        switch self {
        case .none:
            return "nosign"
        case .ripple:
            return "waveform"
        }
    }
}
