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
    
    var id = "priceOptionRow"
    @Namespace var nm
    
    var body: some View {
        Section("Price Settings") {
            NavigationLink {
                PriceOptionView()
                    .environmentObject(priceManager)
                    .environmentObject(uiManager)
                    .navigationTransition(.zoom(sourceID: id, in: nm))
            } label: {
                HStack {
                    Text("Price Option")
                    Spacer()
                    Text(priceManager.comEdPriceOption.rawValue)
                        .foregroundStyle(.secondary)
                }
                .overlay {
                    Color.clear
                        .matchedTransitionSource(id: id, in: nm)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
