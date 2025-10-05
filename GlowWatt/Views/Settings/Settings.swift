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
//                PriceHeightSettings()
                HapticSettings()
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
        Section("Price Options") {
            Picker("Price Option", selection: $priceManager.comEdPriceOption) {
                ForEach(ComdEdPriceOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
            
            Toggle("Show Option on Home", isOn: $uiManager.showPriceOptionOnHome)
                .onChange(of: uiManager.showPriceOptionOnHome) { _, val in
                    uiManager.saveShowPriceOptionOnHome()
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
                Label("Price Height", systemImage: "slider.horizontal.3")
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
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

// MARK: - Haptic Setings
struct HapticSettings: View {
    
    @EnvironmentObject var uiManager: UIManager
    var body: some View {
        Picker("Haptic Style", selection: $uiManager.hapticStyle) {
            ForEach(HapticStyle.allCases, id: \.self) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.navigationLink)
        .onChange(of: uiManager.hapticStyle) { _, value in
            uiManager.saveHapticPreference()
        }
    }
}

// MARK: - History Settings

struct HistorySettings: View {
    var body: some View {
        Section("History") {
            NavigationLink(destination: HistoryView(for: HistoryViewState.currentHistory)) {
                HStack {
                    Label("View History", systemImage: "clock.arrow.circlepath")
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            
            NavigationLink(destination: HistoryView(for: HistoryViewState.historyCount)) {
                HStack {
                    Label("Max History Count", systemImage: "clock")
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
        }
    }
}

// MARK: - Issues Settings
struct IssuesSettings: View {
    var body: some View {
        Section("Issues") {
            NavigationLink(destination: SubmitFeedbackView()) {
                HStack {
                    Label("Submit Feedback", systemImage: "bubble.left.and.bubble.right")
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
    }
}


struct AboutSettings: View {
    var body: some View {
        Section("About") {
            Link(destination: URL(string: "https://aryanrogye.github.io/GlowWatt/privacy-policy")!) {
                HStack {
                    Label("Privacy Policy", systemImage: "doc.text")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            Link(destination: URL(string: "https://github.com/aryanrogye/GlowWatt")!) {
                HStack {
                    Label("Source Code", systemImage: "chevron.left.slash.chevron.right")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
}


#Preview {
    Settings()
}
