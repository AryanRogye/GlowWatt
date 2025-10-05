//
//  GlowWattApp.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import SwiftUI

@main
struct GlowWattApp: App {
    
    @StateObject private var priceProvider = PriceManager()
    @StateObject private var uiManager = UIManager()
    @StateObject private var liveActivitiesStart = LiveActivitesManager()
    
    init() {
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Home()
                    .environmentObject(priceProvider)
                    .environmentObject(uiManager)
                    .environmentObject(liveActivitiesStart)
                    .onOpenURL { url in
                        if url.scheme == "glowwatt", url.host == "refresh" {
                            Task {
                                await priceProvider.refresh()
                            }
                        }
                    }
                    .task {
                        if priceProvider.onHaptic == nil {
                            priceProvider.onHaptic = { [weak uiManager] in
                                uiManager?.hapticStyle.playHaptic()
                            }
                        }
                    }
            }
        }
    }
}
