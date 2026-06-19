//
//  DateExtracter.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 6/18/26.
//

import Foundation
import FoundationModels
import AppIntents

@available(iOS 26.0, *)
@Generable
public struct SearchDate: Hashable, Codable, Equatable, Sendable {
    @Guide(description: """
    The requested date/time as a full ISO-8601 string including timezone offset.
    Example: 2026-06-17T12:00:00-05:00
    Return nil if no date was mentioned.
    """)
    public var dateText: String?
    
    public init(dateText: String? = nil) {
        self.dateText = dateText
    }
}

@available(iOS 26.0, *)
final class DateExtracter {
    public static func extract(criteria: StringSearchCriteria) async throws -> (Double, Date, Date) {
        
        /// Ask Model to extract date
        guard let response = try await Self.extract(from: criteria.term) else {
            throw DateExtracterError.cantConvertCriteriaToDate
        }
        
        /// string -> date formatter
        let formatter = ISO8601DateFormatter()
        
        guard
            let dateText = response.dateText,
            let date = formatter.date(from: dateText)
        else {
            throw DateExtracterError.dateStringMalformed(response.dateText)
        }
        
        let prices = await UserPricesManager.shared.prices
        /// find the data closed to date variable
        
        let dates = prices.map(\.date)
        let closest = dates.min { a, b in
            abs(a.timeIntervalSince(date)) < abs(b.timeIntervalSince(date))
        }
        guard let closest else {
            throw DateExtracterError.couldntFindClosestDate
        }
        
        guard let price = prices.first(where: { $0.date == closest }) else {
            throw DateExtracterError.somethingWentWrongFindingDate
        }
        
        return (price.price, date, closest)
    }
    
    private static func extract(from query: String) async throws -> SearchDate? {
        let session = LanguageModelSession(instructions: """
        Your only job is to take the search criteria and extract the date
        requested in the text, if there is no mention of a date return nil
        in the date flag, the current date is \(Date.now.formatted())
        """)
        
        let result = try await session.respond(to: query, generating: SearchDate.self)
        return result.content
    }
}

enum DateExtracterError: Error, LocalizedError {
    case cantConvertCriteriaToDate
    case dateStringMalformed(String?)
    case couldntFindClosestDate
    case somethingWentWrongFindingDate
    
    var errorDescription: String? {
        switch self {
        case .cantConvertCriteriaToDate:
            "Couldnt Convert Criteria To Date"
        case .dateStringMalformed(let string):
            "Date String Malformed: \(string, default: "nil")"
        case .couldntFindClosestDate:
            "Couldnt Find Closest Date"
        case .somethingWentWrongFindingDate:
            "Something Went Wrong Finding Date"
        }
    }
}
