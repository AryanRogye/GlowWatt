//
//  Settings.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI

struct Settings: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var uiManager: UIManager
    
    var body: some View {
        VStack {
            Form {
                liveDisplayControlOption
                historySection
                issuesSection
                aboutSection
            }
        }
    }
    
    private var issuesSection: some View {
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
    
    private var aboutSection: some View {
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
    
    private var historySection: some View {
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
    
    // Live Display Control
    private var liveDisplayControlOption: some View {
        Section("Appearance") {
            Button(action: handleLiveDisplayControl) {
                HStack {
                    Label("Live Display Control", systemImage: "slider.horizontal.3")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    
    private func handleLiveDisplayControl() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            uiManager.activatePriceHeightModal = true
        }
    }
}

#Preview {
    Settings()
}
