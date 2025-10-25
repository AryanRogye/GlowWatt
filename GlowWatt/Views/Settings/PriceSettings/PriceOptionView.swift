//
//  PriceOptionView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/25/25.
//

import SwiftUI

struct PriceOptionView: View {
    
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager

    var body: some View {
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
    }
}
