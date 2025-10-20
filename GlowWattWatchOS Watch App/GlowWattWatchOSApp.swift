//
//  GlowWattWatchOSApp.swift
//  GlowWattWatchOS Watch App
//
//  Created by Aryan Rogye on 5/29/25.
//

import SwiftUI

@main
struct GlowWattWatchOS_Watch_AppApp: App {
    
    @State private var priceProvider = PriceProvider()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(priceProvider)
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
