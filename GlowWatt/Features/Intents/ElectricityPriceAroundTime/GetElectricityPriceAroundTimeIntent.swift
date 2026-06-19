//
//  GetElectricityPriceAroundTimeIntent.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 6/18/26.
//

import AppIntents

@available(iOS 26.0, *)
@AppIntent(schema: .system.search)
struct GetElectricityPriceAroundTimeIntent: AppIntent, ShowInAppSearchResultsIntent, TargetContentProvidingIntent {
    
    static let searchScopes: [StringSearchScope] = [.general]

    static let title: LocalizedStringResource = "Get Electricity Price Around Time"
    
    @Parameter(title: "Time")
    var criteria: StringSearchCriteria
    
    /// does nothing but is the whole flow
    func perform() async throws -> some IntentResult & ReturnsValue<Double?> & ProvidesDialog {
        let (price, date, closest) = try await DateExtracter.extract(criteria: criteria)
        
        unsafe try await IntentDonationManager.shared.donate(
            intent: self,
            result: .result(value: "Price Closest To \(date.formatted()) was \(price) on \(closest.formatted())")
        )
        
        return .result(
            value: price,
            dialog: IntentDialog(
                "Price Closest To \(date.formatted()) was \(price) on \(closest.formatted())"
            )
        )
    }
}
