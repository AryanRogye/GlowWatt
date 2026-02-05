//
//  AppIntent.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/6/25.
//

import SwiftUI
import AppIntents
import WidgetKit

struct FetchCurrentInstantHourlyPrice: AppIntent {
    static let cooldown: TimeInterval = 5 * 60

    static let title : LocalizedStringResource = "Fetch Current Hourly Price"
    
    enum PriceError: LocalizedError {
        case unavailable
        var errorDescription: String? { "Couldn’t fetch the current price." }
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Double> {
        let now = Date()
        let last: Date = await MainActor.run {
            var last : Date
            last = AppStorage.getLastUpdated() ?? .distantPast
            return last
        }
        
        if now.timeIntervalSince(last) < Self.cooldown {
            let cached = await MainActor.run {
                return AppStorage.getPrice() ?? 0.0
            }
            return .result(value: cached)
        }
        
        // Fetch + persist
        guard let price = await API.fetchComEdPrice(option: .instantHourlyPrice) else {
            throw PriceError.unavailable
        }
        
        await MainActor.run { [price, now] in
            AppStorage.setPrice(price)
            AppStorage.setLastUpdated(now)
        }
        WidgetCenter.shared.reloadAllTimelines()
        return .result(value: price)
    }
}
