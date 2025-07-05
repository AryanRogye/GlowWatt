//
//  ContentView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @EnvironmentObject private var versionChecker: VersionChecker
    
    var body: some View {
        NavigationStack {
            if let lVersion = versionChecker.latestVersion {
                if lVersion == versionChecker.currentVersion {
                    Home()
                } else {
                    isNotUpToDateView
                }
            } else {
                /// This means Checking For version number still
                ProgressView("Checking for updates...")
                    .onAppear {
                        versionChecker.fetchLatestVersion()
                    }
            }
        }
    }
    
    private var isNotUpToDateView: some View {
        VStack(spacing: 16) {
            
            if let image = UIImage(named: "AppLogo") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.red)
            }
            
            Text("Update Available")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Please update to the latest version on TestFlight or the App Store to continue using GlowWatt.")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Current Version: \(versionChecker.currentVersion)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Latest Version: \(versionChecker.latestVersion ?? "Unknown")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(VersionChecker())
        .environmentObject(PriceProvider())
        .environmentObject(UIManager())
}
