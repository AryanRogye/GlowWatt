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

final class API {
    static func fetchComEdPrice() async -> Double? {
//        let url = URL(string: "https://hourlypricing.comed.com/rrtpmobile/servlet?type=instanthourly")!
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
