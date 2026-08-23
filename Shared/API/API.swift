//
//  API.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import UIKit

struct ComEdPrice: Decodable {
    let price: String
}

enum ComdEdPriceOption: String, CaseIterable {
    case instantHourlyPrice = "Instant Hourly Price"
    case currentHourAveragePrice = "Current Hour Average Price"
}

final class API {
    static func fetchComEdPrice(
        option: ComdEdPriceOption = .instantHourlyPrice
    ) async -> Double? {
        if option == .instantHourlyPrice {
            return await getInstantHourlyPrice()
        } else if option == .currentHourAveragePrice {
            return await getHourlyAveragePrice()
        }
        return nil
    }
}

extension API {

    private struct InstantHourlyPrice: Decodable {
        let dateTime: String
        let hourlyVal: String
        let hourlyTitle: String
    }

    private static func getInstantHourlyPrice() async -> Double? {
        let url = URL(
            string: "https://hourlypricing.comed.com/rrtpmobile/servlet?type=instanthourly"
        )!

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let response = try JSONDecoder().decode(
                InstantHourlyPrice.self,
                from: data
            )

            return Double(response.hourlyVal)
        } catch {
            print("error: \(error)")
            return nil
        }
    }
}


extension API {
    private static func getHourlyAveragePrice() async -> Double? {
        let url = URL(string: "https://hourlypricing.comed.com/api?type=currenthouraverage&format=json")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([ComEdPrice].self, from: data)
            if let firstPrice = decoded.first {
                return Double(firstPrice.price)
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
