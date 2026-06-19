//
//  PriceDateEntity.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 6/19/26.
//

import AppIntents

#if compiler(>=6.4)
@available(iOS 27.0, *)
@AppEntity(schema: .calendar.calendar)
public struct PriceDateEntity: IndexedEntity {
    
    public static let defaultQuery = PriceDateQuery()
    
    // MARK: - Properties
    
    var title: String {
        let priceLabel = price.formatted(
            .number.precision(.fractionLength(2))
        )
        return "\(priceLabel) cents/kWh on \(date.formatted(date: .abbreviated, time: .shortened))"
    }

    public var id: UUID
    
    /// price of electricity
    var price: Double
    
    /// date of when electricity was stored
    var date: Date
    
    public var displayRepresentation:
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

@available(iOS 27.0, *)
extension PriceDateEntity {
    public struct PriceDateQuery: EnumerableEntityQuery {
        
        public init() {}
        
        public func allEntities() async throws -> [PriceDateEntity] {
            await UserPricesManager.shared.loadPrices()
            await UserPricesManager.shared.loadMaxPricesHistory()
            let prices = await UserPricesManager.shared.prices
            
            return prices.map(\.dateEntity)
        }
        
        public func entities(for identifiers: [PriceDateEntity.ID]) async throws -> [PriceDateEntity] {
            await UserPricesManager.shared.loadPrices()
            await UserPricesManager.shared.loadMaxPricesHistory()
            let prices = await UserPricesManager.shared.prices
            
            return prices
                .filter { identifiers.contains($0.id) }
                .map(\.dateEntity)
        }
    }
}
#endif
