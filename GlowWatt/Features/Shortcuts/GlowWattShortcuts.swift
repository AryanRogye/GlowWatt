//
//  GlowWattShortcuts.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/27/26.
//

import AppIntents
import GlowWattIntentsKit

struct GlowWattShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FetchCurrentInstantHourlyPrice(),
            phrases: [
                "What is the current hourly price in \(.applicationName)",
                "Get the current electricity price in \(.applicationName)",
                "Check ComEd pricing in \(.applicationName)"
            ],
            shortTitle: "Current Price",
            systemImageName: "bolt.fill"
        )

        if #available(iOS 26, *) {
            AppShortcut(
                intent: GetElectricityPriceAroundTimeIntent(),
                phrases: [
                    "Get electricity price around time in \(.applicationName)",
                    "Check past electricity price in \(.applicationName)",
                    "Check past electricity price in \(.applicationName) Around the time "
                ],
                shortTitle: "Price Around Time",
                systemImageName: "dollarsign.arrow.circlepath"
            )
        }
    }
}
