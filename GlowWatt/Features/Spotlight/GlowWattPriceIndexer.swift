//
//  GlowWattPriceIndexer.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 6/18/26.
//

import CoreSpotlight
import AppIntents

enum GlowWattPriceIndexer {
    private static var index: CSSearchableIndex {
        CSSearchableIndex(name: "GlowWatt_Electricity_Prices")
    }
    
#if compiler(>=6.4)
    private static var dateIndex: CSSearchableIndex {
        .init(name: "GlowWatt_Electricity_Prices_By_Date")
    }
#endif

    @MainActor
    static func donatePrices() async throws {
        let priceEntity = UserPricesManager.shared.prices.map(\.entity)
        try await index.indexAppEntities(priceEntity)
        
#if compiler(>=6.4)
        if #available(iOS 27.0, *) {
            let dateEntity = UserPricesManager.shared.prices.map(\.dateEntity)
            try await dateIndex.indexAppEntities(dateEntity)
        }
#endif
    }
    
    @available(iOS 27.0, *)
    static func deleteDatePrices(identifiedBy identifiers: [UUID]) async throws {
        guard !identifiers.isEmpty else { return }

#if compiler(>=6.4)
        try await dateIndex.deleteAppEntities(
            identifiedBy: identifiers,
            ofType: PriceDateEntity.self
        )
#endif
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
