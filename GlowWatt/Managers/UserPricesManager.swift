//
//  UserPricesManager.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/5/25.
//

import Foundation
import AppIntents
import CoreSpotlight

/// This Class is Managed in the Settings
///
public struct PricesStorage: Codable, Hashable, Identifiable, Sendable {
    public var id = UUID()
    var price: Double
    var date: Date
}

extension PricesStorage {
    var entity: PricesStorageEntity {
        PricesStorageEntity(price: self)
    }
#if compiler(>=6.4)
    @available(iOS 27.0, *)
    var dateEntity: PriceDateEntity {
        PriceDateEntity(price: self)
    }
#endif
}

@MainActor
public final class UserPricesManager: ObservableObject {
    public static let shared = UserPricesManager()

    @Published var prices: [PricesStorage] = []
    @Published var maxPricesHistory: Int = 100

    private init() {
        loadPrices()
        loadMaxPricesHistory()
    }

    public func resetValues() {
        let deletedPriceIDs = prices.map(\.id)

        // 1. Clear in-memory data
        prices.removeAll()
        maxPricesHistory = 100

        // 2. Remove persisted data
        AppStorage.defaults?.removeObject(forKey: "userPrices")
        AppStorage.defaults?.removeObject(forKey: "maxPricesHistory")

        // 3. Persist defaults back
        savePrices()
        saveMaxPricesHistory()

        Task {
            do {
                if deletedPriceIDs.isEmpty {
                    try await GlowWattPriceIndexer.deleteAllPrices()
                } else {
                    try await GlowWattPriceIndexer.deletePrices(identifiedBy: deletedPriceIDs)
                    if #available(iOS 27.0, *) {
                        try await GlowWattPriceIndexer.deleteDatePrices(identifiedBy: deletedPriceIDs)
                    }
                }
            } catch {
                print("Error Removing Prices from Core Spotlight")
            }
        }
    }
    public func resetMaxPriceHistory() {
        maxPricesHistory = 100
        saveMaxPricesHistory()
    }

    // MARK: - Prices
    public func deletePrice(_ price: PricesStorage) {
        prices.removeAll(where: { $0.id == price.id })
        savePrices()

        Task {
            do {
                try await GlowWattPriceIndexer.deletePrices(identifiedBy: [price.id])
                if #available(iOS 27.0, *) {
                    try await GlowWattPriceIndexer.deleteDatePrices(identifiedBy: [price.id])
                }
            } catch {
                print("Error Removing Price from Core Spotlight")
            }
        }
    }

    public func addStorage(for price: Double) {
        self.prices.append(PricesStorage(price: price, date: Date()))
        self.removeEarliestPrices()
        self.savePrices()

        Task {
            do {
                try await GlowWattPriceIndexer.donatePrices()
            } catch {
                print("Error Donating Prices to Core Spotlight")
            }
        }
    }

    private func savePrices() {
        do {
            let data = try JSONEncoder().encode(prices)
            AppStorage.defaults?.set(data, forKey: "userPrices")
        } catch {
            print("failed to save prices: \(error)")
        }
    }

    public func loadPrices() {
        let storedData = AppStorage.defaults?.data(forKey: "userPrices")
            ?? UserDefaults.standard.data(forKey: "userPrices")

        if let data = storedData {
            do {
                let decoded = try JSONDecoder().decode([PricesStorage].self, from: data)
                self.prices = decoded
                AppStorage.defaults?.set(data, forKey: "userPrices")
            } catch {
                print("failed to load prices: \(error)")
                self.prices = []
            }
        } else {
            self.prices = []
        }
    }

    private func removeEarliestPrices() {
        // Remove the earliest prices if the count exceeds maxPricesHistory
        if prices.count > maxPricesHistory {
            let sortedPrices = prices.sorted { $0.date < $1.date }
            let trimmed = Array(sortedPrices.suffix(maxPricesHistory))
            let trimmedIDs = Set(trimmed.map(\.id))
            let removedIDs = prices
                .map(\.id)
                .filter { !trimmedIDs.contains($0) }

            self.prices = trimmed
            savePrices()

            Task {
                do {
                    try await GlowWattPriceIndexer.deletePrices(identifiedBy: removedIDs)
                    if #available(iOS 27.0, *) {
                        try await GlowWattPriceIndexer.deleteDatePrices(identifiedBy: removedIDs)
                    }
                } catch {
                    print("Error Removing Trimmed Prices from Core Spotlight")
                }
            }
        }
    }

    // MARK: - History Count

    public func getHistoryCount() -> Int {
        return prices.count
    }

    public func setMaxPricesHistory(_ count: Int) {
        maxPricesHistory = count
        removeEarliestPrices()
        savePrices()
        saveMaxPricesHistory()
    }

    private func saveMaxPricesHistory() {
        AppStorage.defaults?.set(maxPricesHistory, forKey: "maxPricesHistory")
    }

    public func loadMaxPricesHistory() {
        let storedCount = AppStorage.defaults?.value(forKey: "maxPricesHistory")
            ?? UserDefaults.standard.value(forKey: "maxPricesHistory")

        if let count = storedCount as? Int {
            maxPricesHistory = count
            AppStorage.defaults?.set(count, forKey: "maxPricesHistory")
        } else {
            maxPricesHistory = 100 // Default value if not set
        }
    }
}
