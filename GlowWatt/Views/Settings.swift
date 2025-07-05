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
            }
        }
    }
    
    // Live Display Control
    private var liveDisplayControlOption: some View {
        Section("Appearance") {
            Button(action: handleLivdeDisplayControl) {
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
    
    private func handleLivdeDisplayControl() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            uiManager.activatePriceHeightModal = true
        }
    }
}

#Preview {
    Settings()
}
