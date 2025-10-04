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
    private func loadDefaults() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            "priceHeight": 200,
            "showPriceOptionOnHome": true
        ])
        
        if let priceHeight = defaults.object(forKey: "priceHeight") as? CGFloat {
            self.priceHeight = priceHeight
        } else {
            self.priceHeight = 200 // Default value if not set
        }
        showPriceOptionOnHome = defaults.bool(forKey: "showPriceOptionOnHome")
    }
    
    public func savePriceHeight() {
        let defaults = UserDefaults.standard
        defaults.set(priceHeight, forKey: "priceHeight")
    }
    
    public func saveShowPriceOptionOnHome() {
        let defaults = UserDefaults.standard
        defaults.set(showPriceOptionOnHome, forKey: "showPriceOptionOnHome")
    }
}

