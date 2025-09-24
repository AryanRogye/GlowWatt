//
//  AppStorage.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//
import Foundation

final class AppStorage {
    static let suiteName = "group.com.aryanrogye.glowwatt"
    static let defaults = UserDefaults(suiteName: suiteName)
    
    // MARK: - Keys
    private enum Keys {
        static let lastUpdated = "lastUpdated"
        static let latestPrice = "latestPrice"
    }
    
    // MARK: - Price
    static func setPrice(_ price: Double) {
        defaults?.set(price, forKey: Keys.latestPrice)
    }
    
    static func getPrice() -> Double? {
        return defaults?.double(forKey: Keys.latestPrice)
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
