//
//  OnboardingManager.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import SwiftUI

@Observable @MainActor
final class OnboardingManager {
    private(set) var needsOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        needsOnboarding = false
    }
    
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        needsOnboarding = true
    }
}
