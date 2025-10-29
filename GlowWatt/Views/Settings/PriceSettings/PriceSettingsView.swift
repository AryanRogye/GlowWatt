//
//  PriceSettingsView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/24/25.
//

import SwiftUI

// MARK: - Price Settings
struct PriceSettingsView: View {
    
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager
    
    
    @State private var showFullScreenOverlay = false
    
    var id = "priceOptionRow"
    @Namespace var nm
    
    var body: some View {
        Section("Price Settings") {
            HStack {
                Text("Price Option")
                Spacer()
                Text(priceManager.comEdPriceOption.rawValue)
                    .foregroundStyle(.secondary)
            }
            .matchedTransitionSource(id: id, in: nm)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                showFullScreenOverlay = true
            }
            .fullScreenCover(isPresented: $showFullScreenOverlay) {
                NavigationStack {
                    PriceOptionView()
                        .environmentObject(priceManager)
                        .environmentObject(uiManager)
                        .navigationTransition(.zoom(sourceID: id, in: nm))
                        .toolbarCancel($showFullScreenOverlay)
                }
            }
        }
    }
}
