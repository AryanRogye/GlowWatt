//
//  AppIntent.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/6/25.
//

import SwiftUI
import AppIntents

struct FetchCurrentInstantHourlyPrice: AppIntent {
    
    static let title : LocalizedStringResource = "Fetch Current Hourly Price"
    
    enum PriceError: LocalizedError {
        case unavailable
        var errorDescription: String? { "Couldn’t fetch the current price." }
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Double> {
        guard let price = await API.fetchComEdPrice(option: .instantHourlyPrice) else {
            throw PriceError.unavailable
        }
        return .result(value: price)
    }
}
