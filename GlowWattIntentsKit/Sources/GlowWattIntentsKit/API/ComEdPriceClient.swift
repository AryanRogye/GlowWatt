import Foundation

public enum ComEdPriceClient {
    public static func instantHourlyPrice() async -> Double? {
        guard let url = URL(string: "https://hourlypricing.comed.com/rrtpmobile/servlet?type=instanthourly") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let raw = String(data: data, encoding: .utf8) else { return nil }

            let header = raw.components(separatedBy: "<br>").first ?? raw
            let pricePart = header.split(separator: "~", maxSplits: 1).first.map(String.init) ?? header
            let cleaned = pricePart
                .replacingOccurrences(of: "&cent;", with: "")
                .replacingOccurrences(of: "¢", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            return Double(cleaned)
        } catch {
            return nil
        }
    }
}
