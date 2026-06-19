import AppIntents
import Foundation

public struct BestTimeToRunAppliancesIntent: AppIntent {
    public static let title: LocalizedStringResource = "Best Time To Run Appliances"
    public static let description = IntentDescription(
        "Recommends whether now is a good time to run appliances based on the current ComEd price and saved GlowWatt history."
    )

    @Parameter(title: "Appliance", default: "appliances")
    public var appliance: String

    public init() {}

    public func perform() async throws -> some IntentResult & ReturnsValue<Double> & ProvidesDialog {
        let currentPrice = try await Self.currentPrice()
        let recommendation = Self.recommendation(for: currentPrice)
        let formattedCurrentPrice = currentPrice.formatted(.number.precision(.fractionLength(2)))
        let applianceName = normalizedApplianceName

        switch recommendation {
        case .runNow:
            return .result(value: currentPrice, dialog: "Right now is a good time to run \(applianceName). The current price is \(formattedCurrentPrice) cents per kilowatt hour.")
        case .wait(let best):
            let formattedBestPrice = best.price.formatted(.number.precision(.fractionLength(2)))
            let bestTime = best.date.formatted(date: .omitted, time: .shortened)
            return .result(value: currentPrice, dialog: "I'd wait to run \(applianceName). The best recent time was around \(bestTime) at \(formattedBestPrice) cents per kilowatt hour. Right now is \(formattedCurrentPrice) cents.")
        case .needsMoreHistory:
            return .result(value: currentPrice, dialog: "The current price is \(formattedCurrentPrice) cents per kilowatt hour. GlowWatt needs a little more saved history before it can compare the best time to run \(applianceName).")
        }
    }

    private enum Recommendation {
        case runNow
        case wait(GlowWattPrice)
        case needsMoreHistory
    }

    private var normalizedApplianceName: String {
        let trimmed = appliance.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "appliances" : trimmed
    }

    private static func currentPrice() async throws -> Double {
        let now = Date()
        if
            let lastUpdated = GlowWattDataStore.lastUpdated(),
            let cachedPrice = GlowWattDataStore.latestPrice(),
            now.timeIntervalSince(lastUpdated) < 5 * 60
        {
            return cachedPrice
        }

        guard let price = await ComEdPriceClient.instantHourlyPrice() else {
            throw RecommendationError.unavailable
        }

        GlowWattDataStore.saveCurrentPrice(price, updatedAt: now)
        return price
    }

    private static func recommendation(for currentPrice: Double) -> Recommendation {
        let savedPrices = GlowWattDataStore.prices()
        guard !savedPrices.isEmpty else { return .needsMoreHistory }

        let dayAgo = Date().addingTimeInterval(-24 * 60 * 60)
        let recentPrices = savedPrices.filter { $0.date >= dayAgo }
        let comparisonPrices = recentPrices.isEmpty ? savedPrices : recentPrices

        guard let best = comparisonPrices.min(by: { $0.price < $1.price }) else {
            return .needsMoreHistory
        }

        let average = comparisonPrices.map(\.price).reduce(0, +) / Double(comparisonPrices.count)
        let nearBestTolerance = max(0.25, average * 0.05)

        return currentPrice <= best.price + nearBestTolerance || currentPrice <= average * 0.85
            ? .runNow
            : .wait(best)
    }

    private enum RecommendationError: LocalizedError {
        case unavailable

        var errorDescription: String? {
            "Couldn't fetch the current electricity price."
        }
    }
}
