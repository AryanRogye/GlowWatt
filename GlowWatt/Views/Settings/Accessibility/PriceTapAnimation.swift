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
    
    @State var showScreen = false
    
    var body: some View {
        HStack {
            Text("Price Tap Animation")
            Spacer()
            Text(uiManager.priceTapAnimation.rawValue)
                .foregroundStyle(.secondary)
        }
        .matchedTransitionSource(id: id, in: nm)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            showScreen = true
        }

        .fullScreenCover(isPresented: $showScreen) {
            NavigationStack {
                PriceTapSettingsView()
                    .environmentObject(priceManager)
                    .environmentObject(uiManager)
                    .navigationTransition(.zoom(sourceID: id, in: nm))
                    .toolbarCancel($showScreen)
            }
        }
    }
}
