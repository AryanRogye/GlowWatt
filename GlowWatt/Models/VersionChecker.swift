//
//  VersionChecker.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/5/25.
//

import Foundation
import Network

@MainActor
final class VersionChecker: ObservableObject {
    @Published var latestVersion: String? = nil
    let currentVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    
    init() {
        fetchLatestVersion()
    }
    
    func fetchLatestVersion() {
        Task {
            do {
                let url = URL(string: "https://raw.githubusercontent.com/AryanRogye/GlowWatt/main/versionNumber.json")!
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let decoded = try? JSONDecoder().decode(VersionInfo.self, from: data) {
                    DispatchQueue.main.async {
                        self.latestVersion = decoded.version
                    }
                }
            } catch {
                print("Error fetching version: \(error)")
            }
        }
    }
}
struct VersionInfo: Decodable {
    let version: String
}
