//
//  GlowWattApp.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import SwiftUI

@main
struct GlowWattApp: App {
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
