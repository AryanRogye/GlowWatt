//
//  UIManager.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import Foundation
import SwiftUI
import Combine

final class UIManager: ObservableObject {
    
    @Published var activateLimiterModal = false
    @Published var limiterDetent: PresentationDetent = .fraction(0.8)

    @Published var priceHeight: CGFloat = 200
    @Published var activatePriceHeightModal = false
    /// Start True
    @Published var showPriceOptionOnHome = true
    
    @Published var hapticStyle = HapticStyle.medium
    
    @Published var priceTapAnimation : PriceTapAnimations = PriceTapAnimations.ripple
    
    @SwiftUI.AppStorage("MostRecentOnTop") var mostRecentOnTop = true
    @SwiftUI.AppStorage("ShadeHistoryRegion") var shadeHistoryRegion = false
    
    public var shouldUseWave : Bool {
        return priceTapAnimation == .ripple ? true : false
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        loadDefaults()
    }
    
}

// MARK: - Limiter Modal
extension UIManager {
    public func toggleLimiterModal(with price: Double?) {
        if price == nil {
            limiterDetent = .fraction(0.2)
        } else {
            limiterDetent = .fraction(0.8)
        }
        activateLimiterModal.toggle()
    }
}

// MARK: - Price Height Modal
extension UIManager {
    
    public func resetDefaults() {
        priceHeight = 200
        savePriceHeight()
        
        showPriceOptionOnHome = true
        saveShowPriceOptionOnHome()

        hapticStyle = .medium
        saveHapticPreference()
        
        priceTapAnimation = .ripple
        savePriceTapAnimation()
    }
    
    private func loadDefaults() {
        let defaults = UserDefaults.standard
        
        defaults.register(defaults: [
            "priceHeight": 200,
            "showPriceOptionOnHome": true,
            "hapticStyle": HapticStyle.medium.rawValue,
            "priceTapAnimation": PriceTapAnimations.ripple.rawValue,
            "MostRecentOnTop": true
        ])

        if let priceHeight = defaults.object(forKey: "priceHeight") as? CGFloat {
            self.priceHeight = priceHeight
        } else {
            self.priceHeight = 200 // Default value if not set
        }
        showPriceOptionOnHome = defaults.bool(forKey: "showPriceOptionOnHome")
    
        hapticStyle = HapticStyle(rawValue: defaults.string(forKey: "hapticStyle") ?? HapticStyle.medium.rawValue) ?? .medium
        priceTapAnimation = PriceTapAnimations(
            rawValue: defaults.string(forKey: "priceTapAnimation") ?? PriceTapAnimations.ripple.rawValue
        ) ?? .ripple
        
        mostRecentOnTop = defaults.bool(forKey: "MostRecentOnTop")
    }
    
    public func saveMostRecentOnTop() {
        let defaults = UserDefaults.standard
        defaults.set(mostRecentOnTop, forKey: "MostRecentOnTop")
    }
    
    public func savePriceHeight() {
        let defaults = UserDefaults.standard
        defaults.set(priceHeight, forKey: "priceHeight")
    }
    
    public func saveShowPriceOptionOnHome() {
        let defaults = UserDefaults.standard
        defaults.set(showPriceOptionOnHome, forKey: "showPriceOptionOnHome")
    }
    
    public func saveHapticPreference() {
        let defaults = UserDefaults.standard
        defaults.set(hapticStyle.rawValue, forKey: "hapticStyle")
    }
    
    public func savePriceTapAnimation() {
        let defaults = UserDefaults.standard
        defaults.set(priceTapAnimation.rawValue, forKey: "priceTapAnimation")
    }
}

