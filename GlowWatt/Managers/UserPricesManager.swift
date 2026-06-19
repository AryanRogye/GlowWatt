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
        UserDefaults.standard.removeObject(forKey: "userPrices")
        UserDefaults.standard.removeObject(forKey: "maxPricesHistory")

        // 3. Persist defaults back
        savePrices()
        saveMaxPricesHistory()

        Task {
            do {
                if deletedPriceIDs.isEmpty {
                    try await GlowWattPriceIndexer.deleteAllPrices()
                } else {
                    try await GlowWattPriceIndexer.deletePrices(identifiedBy: deletedPriceIDs)
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
            UserDefaults.standard.set(data, forKey: "userPrices")
        } catch {
            print("failed to save prices: \(error)")
        }
    }

    public func loadPrices() {
        if let data = UserDefaults.standard.data(forKey: "userPrices") {
            do {
                let decoded = try JSONDecoder().decode([PricesStorage].self, from: data)
                self.prices = decoded
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
        UserDefaults.standard.set(maxPricesHistory, forKey: "maxPricesHistory")
    }

    public func loadMaxPricesHistory() {
        if let count = UserDefaults.standard.value(forKey: "maxPricesHistory") as? Int {
            maxPricesHistory = count
        } else {
            maxPricesHistory = 100 // Default value if not set
        }
    }
}
