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
    
    var body: some View {
        VStack {
            Form {
                PriceSettings()
                AccessibilitySettings()
                HistorySettings()
                IssuesSettings()
                AboutSettings()
            }
        }
    }
}

// MARK: - Price Settings
struct PriceSettings: View {
    
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager
    
    var body: some View {
        Section("Price Settings") {
            NavigationLink {
                List {
                    ForEach(ComdEdPriceOption.allCases, id: \.self) { option in
                        HStack {
                            Text(option.rawValue)
                            Spacer()
                            if priceManager.comEdPriceOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            priceManager.comEdPriceOption = option
                        }
                    }
                    
                    Toggle("Show on Home Screen", isOn: $uiManager.showPriceOptionOnHome)
                        .onChange(of: uiManager.showPriceOptionOnHome) { _, _ in
                            uiManager.saveShowPriceOptionOnHome()
                        }
                }
                .navigationTitle("Price Option")
            } label: {
                HStack {
                    Text("Price Option")
                    Spacer()
                    Text(priceManager.comEdPriceOption.rawValue)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Haptic Setings
struct AccessibilitySettings: View {
    
    @EnvironmentObject var uiManager: UIManager
    var body: some View {
        
        Section("Accessibility") {
            List {
                Picker("Strength", selection: $uiManager.hapticStyle) {
                    ForEach(HapticStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .onChange(of: uiManager.hapticStyle) { _, value in
                    uiManager.saveHapticPreference()
                }
            }
            PriceHeightSettings()
        }
    }
}

// MARK: - Price Height Settings
struct PriceHeightSettings: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager
    
    var body: some View {
        Button(action: handleLiveDisplayControl) {
            HStack {
                Text("Price Height")
                    .foregroundColor(.primary)
                Spacer()
                Text("\(Int(uiManager.priceHeight)) pt")
                    .foregroundStyle(.secondary)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func handleLiveDisplayControl() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            uiManager.activatePriceHeightModal = true
        }
    }
}

// MARK: - History Settings

struct HistorySettings: View {
    var body: some View {
        Section("History") {
            NavigationLink("View History") {
                HistoryView(for: HistoryViewState.currentHistory)
            }
            
            NavigationLink("Max History Count") {
                HistoryView(for: HistoryViewState.historyCount)
            }
        }
    }
}

// MARK: - Issues Settings
struct IssuesSettings: View {
    var body: some View {
        Section("Issues") {
            NavigationLink("Submit Feedback") {
                SubmitFeedbackView()
            }
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


#Preview {
    Settings()
}
