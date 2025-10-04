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
            return await getInstantHourlyPrice()
        }
        return nil
    }
}

extension API {
    private static func getInstantHourlyPrice() async -> Double? {
        let url = URL(string: "https://hourlypricing.comed.com/rrtpmobile/servlet?type=instanthourly")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let raw = String(data: data, encoding: .utf8) else {
                return nil
            }
            
            // Expected format: "3.8&cent;~Real-Time Hourly Price<br>10-11 PM CT"
            // 1) Take the header before <br>
            let header = raw.components(separatedBy: "<br>").first ?? raw
            // 2) Take the price part before ~
            let pricePart = header.split(separator: "~", maxSplits: 1).first.map(String.init) ?? header
            // 3) Remove cent symbol/entity and trim
            let cleaned = pricePart
                .replacingOccurrences(of: "&cent;", with: "")
                .replacingOccurrences(of: "¢", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Convert to Double (this is the value in cents, e.g., 3.8 means 3.8¢)
            guard let priceCents = Double(cleaned) else {
                return nil
            }
            
            // If you prefer dollars instead of cents, return priceCents / 100.0
            return priceCents
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
