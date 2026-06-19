//
//  AppIntent.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/6/25.
//

import SwiftUI
import AppIntents
import WidgetKit

/// This Intent is used for the Widget Target and for Apple Shortcuts
struct FetchCurrentInstantHourlyPrice: AppIntent {
    static let cooldown: TimeInterval = 5 * 60

    static let title : LocalizedStringResource = "Fetch Current Hourly Price"
    
    enum PriceError: LocalizedError {
        case unavailable
        var errorDescription: String? { "Couldn’t fetch the current price." }
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Double> & ProvidesDialog {
        let now = Date()

        let last = await MainActor.run {
            AppStorage.getLastUpdated() ?? .distantPast
        }

        if now.timeIntervalSince(last) < Self.cooldown {
            let cached = await MainActor.run {
                AppStorage.getPrice() ?? 0.0
            }

            return .result(
                value: cached,
                dialog: "The current hourly price is \(cached) cents per kilowatt hour."
            )
        }

        guard let price = await API.fetchComEdPrice(option: .instantHourlyPrice) else {
            throw PriceError.unavailable
        }

        await MainActor.run {
            AppStorage.setPrice(price)
            AppStorage.setLastUpdated(now)
        }

        WidgetCenter.shared.reloadAllTimelines()

        let formattedPrice = price.formatted(.number.precision(.fractionLength(2)))

        return .result(
            value: price,
            dialog: IntentDialog(
                "The current hourly price is \(formattedPrice) cents per kilowatt hour."
            )
        )
    }
}
