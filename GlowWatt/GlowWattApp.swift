//
//  GlowWattApp.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import SwiftUI

@Observable
@MainActor
final class AppServices {
    let priceProvider = PriceManager()
    let uiManager = UIManager()
    let liveActivitiesStart = LiveActivitesManager()
    let onboardingManager = OnboardingManager()
    
    init() {
        if priceProvider.onHaptic == nil {
           priceProvider.onHaptic = {
                self.uiManager.hapticStyle.playHaptic()
            }
        }
    }
}

@main
struct GlowWattApp: App {
    
    @State var appServices = AppServices()
    
    init() {
        GlowWattShortcuts.updateAppShortcutParameters()
        if #available(iOS 26.0, *) {
            Task {
                do {
                    try await GlowWattPriceIndexer.donatePrices()
                } catch {
                    print("Error Donating Prices to Core Spotlight")
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if appServices.onboardingManager.needsOnboarding {
                OnboardingView()
                    .environment(appServices.onboardingManager)
            } else {
                NavigationStack {
                    Home()
                        .environment(appServices.onboardingManager)
                        .environmentObject(appServices.priceProvider)
                        .environmentObject(appServices.uiManager)
                        .environmentObject(appServices.liveActivitiesStart)
                        .onOpenURL { url in
                            if url.scheme == "glowwatt", url.host == "refresh" {
                                Task {
                                    await appServices.priceProvider.refresh()
                                }
                            }
                        }
                }
            }
        }
    }
}
