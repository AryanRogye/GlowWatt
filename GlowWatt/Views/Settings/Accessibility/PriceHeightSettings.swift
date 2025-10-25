//
//  PriceHeightSettings.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/25/25.
//

import SwiftUI

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
