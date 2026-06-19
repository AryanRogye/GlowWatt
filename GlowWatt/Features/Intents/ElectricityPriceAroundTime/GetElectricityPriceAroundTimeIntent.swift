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
        guard let response = try await DateExtracter.extract(from: criteria.term) else {
            return .result(
                value: nil,
                dialog: IntentDialog(
                    "Something went wrong, please try again later"
                )
            )
        }
        
        let formatter = ISO8601DateFormatter()
        
        guard
            let dateText = response.dateText,
            let date = formatter.date(from: dateText)
        else {
            return .result(
                value: nil,
                dialog: "I couldn't find a valid date in your request."
            )
        }
        
        let prices = await UserPricesManager.shared.prices
        /// find the data closed to date variable
        
        let dates = prices.map(\.date)
        let closest = dates.min { a, b in
            abs(a.timeIntervalSince(date)) < abs(b.timeIntervalSince(date))
        }
        guard let closest else {
            return .result(
                value: nil,
                dialog: IntentDialog(
                    "Something went wrong, please try again later"
                )
            )
        }
        
        guard let price = prices.first(where: { $0.date == closest }) else {
            return .result(
                value: nil,
                dialog: IntentDialog(
                    "Something went wrong, please try again later"
                )
            )
        }
        
        return .result(
            value: price.price,
            dialog: IntentDialog(
                "Price Closest To \(date.formatted()) was \(price.price) on \(closest.formatted())"
            )
        )
    }
}
