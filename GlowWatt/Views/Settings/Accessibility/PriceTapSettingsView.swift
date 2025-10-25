//
//  PriceTapSettingsView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/6/25.
//

import SwiftUI

struct PriceTapSettingsView: View {
    
    @EnvironmentObject var uiManager : UIManager
    
    var body: some View {
        List {
            ForEach(PriceTapAnimations.allCases, id: \.self) { option in
                HStack {
                    Label(option.rawValue, systemImage: option.icon)
                    Spacer()
                    if uiManager.priceTapAnimation == option {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    uiManager.priceTapAnimation = option
                    uiManager.savePriceTapAnimation()
                }
            }
        }
        .navigationTitle("Price Tap Settings")
    }
}

#Preview {
    NavigationStack {
        PriceTapSettingsView()
            .environmentObject(UIManager())
    }
}
