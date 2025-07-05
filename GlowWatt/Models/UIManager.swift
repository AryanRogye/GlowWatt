//
//  UIManager.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import Foundation

final class UIManager: ObservableObject {
    @Published var priceHeight: CGFloat = 200
    @Published var activatePriceHeightModal = false
    
    init() {
        loadDefaults()
    }
    
    private func loadDefaults() {
        let defaults = UserDefaults.standard
        
        if let priceHeight = defaults.object(forKey: "priceHeight") as? CGFloat {
            self.priceHeight = priceHeight
        } else {
            self.priceHeight = 200 // Default value if not set
        }
    }
    
    public func savePriceHeight() {
        let defaults = UserDefaults.standard
        defaults.set(priceHeight, forKey: "priceHeight")
    }
}

