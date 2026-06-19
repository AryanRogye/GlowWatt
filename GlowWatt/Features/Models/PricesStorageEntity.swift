//
//  PricesStorageEntity.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 6/18/26.
//

import AppIntents

struct PricesStorageEntity: IndexedEntity {
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Price")
    
    
    static let defaultQuery = PricesQuery()
    
    // MARK: - Properties
    
    var id: UUID
    
    /// price of electricity
    var price: Double
    
    /// date of when electricity was stored
    var date: Date
    
    var displayRepresentation:
    DisplayRepresentation { DisplayRepresentation(
            title: "\(price, format: .number.precision(.fractionLength(2))) cents/kWh",
            subtitle: "\(date.formatted(date: .abbreviated, time: .shortened))"
        )
    }
    
    init(price: PricesStorage) {
        self.id = price.id
        self.price = price.price
        self.date = price.date
    }
}

extension PricesStorageEntity {
    struct PricesQuery: EntityQuery {
        func entities(for identifiers: [PricesStorageEntity.ID]) async throws -> [PricesStorageEntity] {
            await UserPricesManager.shared.loadPrices()
            await UserPricesManager.shared.loadMaxPricesHistory()
            let prices = await UserPricesManager.shared.prices
            
            return prices
                .filter { identifiers.contains($0.id) }
                .map(\.entity)
        }
    }
}
