//
//  GlowWattApp.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import SwiftUI

@main
struct GlowWattApp: App {
    
    @StateObject private var priceManager: PriceManager
    @StateObject private var uiManager = UIManager()
    @StateObject private var liveActivityManager : LiveActivitesManager
    
    init() {
        let priceManager = PriceManager()
        self._priceManager = .init(wrappedValue: priceManager)
        self._liveActivityManager = .init(wrappedValue: LiveActivitesManager(
            onRefresh: { [weak priceManager] in
                guard let priceManager else { return (nil, nil) }
                return await priceManager.refresh()
            }
        ))
//        self.liveActivitiesStart.bind(to: priceManager)
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Home()
                    .environmentObject(priceManager)
                    .environmentObject(uiManager)
                    .environmentObject(liveActivityManager)
                    .onOpenURL { url in
                        if url.scheme == "glowwatt", url.host == "refresh" {
                            Task {
                                await priceManager.refresh()
                            }
                        }
                    }
                    .onOpenURL { url in
                        if url.scheme == "glowwatt", url.host == "stop_price_watcher" {
                            liveActivityManager.stopLiveActivity()
                        }
                    }

            }
        }
    }
}
