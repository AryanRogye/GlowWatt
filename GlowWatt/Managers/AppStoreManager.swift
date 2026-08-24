//
//  AppStoreManager.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 8/24/26.
//

import Foundation

enum AppVersionStatus {
    case unknown
    case upToDate
    case newVersionAvailable(AppStoreManager.AppInfo)
    case nonAppStoreBuild
}

@Observable
@MainActor
final class AppStoreManager {

    /// this apps current version
    let appVersion = Bundle.main.versionNumber
    var latestAppStoreInfo: AppInfo?

    var appVersionStatus: AppVersionStatus {
        /// if no latestVersionInfo is false then we consider this as
        /// up to date
        guard let latestAppStoreInfo else {
            return .unknown
        }
        
        switch appVersion.compare(
            latestAppStoreInfo.version,
            options: .numeric
        ) {
        case .orderedSame:
            return .upToDate

        case .orderedAscending:
            return .newVersionAvailable(latestAppStoreInfo)

        case .orderedDescending:
            return .nonAppStoreBuild
        }
    }

    init() {
        self.checkLatestAppStoreVersion()
    }

    private struct LookupResponse: Decodable {
        let results: [AppInfo]
    }

    struct AppInfo: Decodable {
        let version: String
        let releaseNotes: String?
        let trackViewUrl: String
    }

    /// this should only be called by the app once at the start
    private func checkLatestAppStoreVersion() {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=6746350564") else {
            return
        }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoded = try JSONDecoder().decode(LookupResponse.self, from: data)
                if let first = decoded.results.first {
                    self.latestAppStoreInfo = first
                }
            } catch {
                print("Error Fetching Latest App Store Version: \(error.localizedDescription)")
            }
        }
    }
}
