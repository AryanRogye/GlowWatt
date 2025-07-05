//
//  GlowWattApp.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import SwiftUI

@main
struct GlowWattApp: App {
    
    @StateObject private var priceProvider = PriceProvider()
    @StateObject private var uiManager = UIManager()
    @StateObject private var versionChecker = VersionChecker()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(priceProvider)
                .environmentObject(uiManager)
                .environmentObject(versionChecker)
                .onOpenURL { url in
                    if url.scheme == "glowwatt", url.host == "refresh" {
                        Task {
                            priceProvider.refresh()
                        }
                    }
                }
        }
    }
}
