import Foundation

public struct GlowWattPrice: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var price: Double
    public var date: Date
}

public enum GlowWattDataStore {
    public static let suiteName = "group.com.aryanrogye.glowwatt"

    private static let pricesKey = "userPrices"
    private static let latestPriceKey = "latestPrice"
    private static let lastUpdatedKey = "lastUpdated"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    public static func prices() -> [GlowWattPrice] {
        guard
            let data = defaults?.data(forKey: pricesKey),
            let prices = try? JSONDecoder().decode([GlowWattPrice].self, from: data)
        else {
            return []
        }

        return prices
    }

    public static func savePrices(_ prices: [GlowWattPrice]) {
        guard let data = try? JSONEncoder().encode(prices) else { return }
        defaults?.set(data, forKey: pricesKey)
    }

    public static func latestPrice() -> Double? {
        guard defaults?.object(forKey: latestPriceKey) != nil else { return nil }
        return defaults?.double(forKey: latestPriceKey)
    }

    public static func lastUpdated() -> Date? {
        defaults?.object(forKey: lastUpdatedKey) as? Date
    }

    public static func saveCurrentPrice(_ price: Double, updatedAt date: Date) {
        defaults?.set(price, forKey: latestPriceKey)
        defaults?.set(date, forKey: lastUpdatedKey)
    }
}
