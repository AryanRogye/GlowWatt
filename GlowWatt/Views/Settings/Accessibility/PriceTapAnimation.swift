//
//  PriceTapAnimation.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/25/25.
//

import SwiftUI

struct PriceTapAnimation: View {
    
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager
    
    var id = "priceTapAnimation"
    @Namespace var nm
    
    var body: some View {
        NavigationLink {
            PriceTapSettingsView()
                .environmentObject(priceManager)
                .environmentObject(uiManager)
                .navigationTransition(.zoom(sourceID: id, in: nm))
        } label: {
            HStack {
                Text("Price Tap Animation")
                Spacer()
                Text(uiManager.priceTapAnimation.rawValue)
                    .foregroundStyle(.secondary)
            }
            .overlay {
                Color.clear
                    .matchedTransitionSource(id: id, in: nm)
            }
        }
    }
}
