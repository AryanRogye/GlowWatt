//
//  API.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import UIKit

final class API {
    static func fetchComEdPrice() async -> Double? {
        let url = URL(string: "https://hourlypricing.comed.com/rrtpmobile/servlet?type=instanthourly")!
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let string = String(data: data, encoding: .utf8),
                  let priceText = string.components(separatedBy: "&cent;").first,
                  let price = Double(priceText.trimmingCharacters(in: .whitespacesAndNewlines))
            else {
                return nil
            }
            return price
        } catch {
            return nil
        }
    }
}
