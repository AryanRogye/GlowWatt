//
//  AppStorage.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//
import Foundation

@MainActor
final class AppStorage {
    static let suiteName = "group.com.aryanrogye.glowwatt"
    static let defaults = UserDefaults(suiteName: suiteName)
    
    // MARK: - Keys
    private enum Keys {
        static let lastUpdated = "lastUpdated"
        static let latestPrice = "latestPrice"
        static let userPrices = "userPrices"
        static let maxPricesHistory = "maxPricesHistory"
    }

    private struct StoredPrice: Codable {
        var id = UUID()
        var price: Double
        var date: Date
    }
    
    // MARK: - Price
    static func setPrice(_ price: Double) {
        defaults?.set(price, forKey: Keys.latestPrice)
    }
    
    static func getPrice() -> Double? {
        return defaults?.double(forKey: Keys.latestPrice)
    }

    static func addPriceToHistory(_ price: Double, date: Date = Date()) {
        let storedData = defaults?.data(forKey: Keys.userPrices)
            ?? UserDefaults.standard.data(forKey: Keys.userPrices)

        var prices: [StoredPrice] = []

        if let storedData {
            guard let decoded = try? JSONDecoder().decode([StoredPrice].self, from: storedData) else {
                return
            }
            prices = decoded
        }

        if let latest = prices.max(by: { $0.date < $1.date }),
           latest.price == price,
           date.timeIntervalSince(latest.date) < 60 {
            return
        }

        prices.append(StoredPrice(price: price, date: date))

        let maxPricesHistory = defaults?.integer(forKey: Keys.maxPricesHistory) ?? 0
        let historyLimit = maxPricesHistory > 0 ? maxPricesHistory : 100

        if prices.count > historyLimit {
            prices = Array(prices.sorted { $0.date < $1.date }.suffix(historyLimit))
        }

        guard let data = try? JSONEncoder().encode(prices) else { return }
        defaults?.set(data, forKey: Keys.userPrices)
    }
    
    // MARK: - Timestamp
    static func setLastUpdated(_ date: Date = Date()) {
        defaults?.set(date, forKey: Keys.lastUpdated)
    }
    
    static func getLastUpdated() -> Date? {
        return defaults?.object(forKey: Keys.lastUpdated) as? Date
    }
    
    static func getFormattedLastUpdated() -> String {
        guard let date = getLastUpdated() else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
