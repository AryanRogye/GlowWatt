//
//  Settings.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI

struct Settings: View {
    
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager
    @Environment(OnboardingManager.self) var onboardingManager
    
    @State private var onAppear = false
    @State private var shouldShowReset = false
    @State private var shouldShowHistoryReset = false
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                PriceSettingsView()
                AccessibilitySettings()
                HistorySettings()
                IssuesSettings()
                AboutSettings()
                ResetOnboarding()
            }
            .environmentObject(priceManager)
            .environmentObject(uiManager)
            
        }
        .transition(.opacity)
        .opacity(onAppear ? 1 : 0)
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                onAppear = true
            }
        }
        .onDisappear {
            onAppear = false
        }
        .navigationTitle("Settings")
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    shouldShowReset = true
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(.primary)
                }
            }
        }
        .alert("Reset Values",
               isPresented: $shouldShowReset) {
            
            Button("Cancel", role: .cancel) {
                shouldShowReset = false
            }
            
            Button(action: {
                shouldShowReset = false
                // run your reset logic
                shouldShowHistoryReset = true
            }) {
                Text("Reset All Values")
            }
            
        } message: {
            Text("Are you sure you want to reset all saved values?")
        }
        /// Final Reset
        .alert("Clear History As Well?", isPresented: $shouldShowHistoryReset) {
            
            Button("Cancel", role: .cancel) {
                shouldShowHistoryReset = false
            }
            
            Button(action: {
                delete(deleteHistory: false)
            }) {
                Text("Reset (keep history)")
            }
            
            Button(action: {
                delete(deleteHistory: true)
            }) {
                Text("Reset & clear history")
            }
            
        } message: {
            Text("This cannot be undone. Graphs may be inaccurate if you keep history.")
        }
    }
    
    private func delete(deleteHistory: Bool) {
        priceManager.resetComEdPriceOption()
        uiManager.resetDefaults()
        if deleteHistory {
            UserPricesManager.shared.resetValues()
        }
    }
}

// MARK: - About Settings
struct AboutSettings: View {
    var body: some View {
        Section("About") {
            Link(destination: URL(string: "https://aryanrogye.github.io/GlowWatt/privacy-policy")!) {
                Text("Privacy Policy")
            }
            
            Link(destination: URL(string: "https://github.com/aryanrogye/GlowWatt")!) {
                Text("Source Code")
            }
            
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Reset Onboarding
struct ResetOnboarding: View {
    
    @Environment(OnboardingManager.self) var onboardingManager
    
    var body: some View {
        Button(action: {
            onboardingManager.resetOnboarding()
        }) {
            Text("Reset Intro")
        }
    }
}

#Preview {
    
    @Previewable @State var onboardingManager = OnboardingManager()
    @Previewable @StateObject var priceManager = PriceManager()
    @Previewable @StateObject var uiManager = UIManager()
    @Previewable @StateObject var liveActivitiesStart = LiveActivitesManager()
    @Previewable @Namespace var nm
    
    NavigationStack {
        Settings()
            .environment(onboardingManager)
            .environmentObject(priceManager)
            .environmentObject(uiManager)
            .environmentObject(liveActivitiesStart)
    }
}
