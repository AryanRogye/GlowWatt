//
//  PriceView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import SwiftUI

struct PriceView: View {
    
    @Environment(PriceProvider.self) var priceProvider
    
    // MARK: - Time Stamp
    private var relativeTimestamp : String {
        
        AppStorage.getLastUpdated()?.formatted(
            Date.RelativeFormatStyle(presentation: .named, unitsStyle: .abbreviated)
        ) ?? "Never"
        
    }

    var body: some View {
        @Bindable var priceProvider = priceProvider
        VStack {
            Spacer()
            Text("Tap To Refresh")
                .foregroundStyle(.white)
                .font(.system(size: 10, weight: .bold))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(5)
                .background(Color.black.opacity(0.5))
                .cornerRadius(8)
            
            if let price = priceProvider.price {
                /// Allow to wrap
                Text("\(price, specifier: "%.2f")¢")
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .font(.system(size: 35, weight: .bold))
                
                Spacer()
                /// Last updated date
                Text(relativeTimestamp)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
            } else {
                Text("Fetching price...")
                    .font(.largeTitle)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
