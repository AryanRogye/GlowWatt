//
//  GlowWattPriceIndexer.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 6/18/26.
//

import CoreSpotlight

enum GlowWattPriceIndexer {
    private static var index: CSSearchableIndex {
        CSSearchableIndex(name: "GlowWatt_Electricity_Prices")
    }

    @MainActor
    static func donatePrices() async throws {
        let priceEntity = UserPricesManager.shared.prices.map(\.entity)
        
        try await index.indexAppEntities(priceEntity)
    }

    static func deletePrices(identifiedBy identifiers: [PricesStorageEntity.ID]) async throws {
        guard !identifiers.isEmpty else { return }

        try await index.deleteAppEntities(
            identifiedBy: identifiers,
            ofType: PricesStorageEntity.self
        )
    }

    static func deleteAllPrices() async throws {
        try await index.deleteAppEntities(ofType: PricesStorageEntity.self)
    }
}
