//
//  GlowWattWatchOSApp.swift
//  GlowWattWatchOS Watch App
//
//  Created by Aryan Rogye on 5/29/25.
//

import SwiftUI

@main
struct GlowWattWatchOS_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if url.scheme == "glowwatt", url.host == "refresh" {
                        Task {
                            PriceProvider.shared.refresh()
                        }
                    }
                }
        }
    }
}
