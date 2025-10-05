//
//  Home.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI

struct Home: View {
    
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager
    @EnvironmentObject var liveActivitesManager: LiveActivitesManager
    
    var priceColor: Color {
        if let price = priceManager.price {
            switch price {
            case ..<4:
                return .green
            case 4..<8:
                return .yellow
            default:
                return .red
            }
        }
        return .gray
    }
    
    
    var body: some View {
        ZStack {
            ScrollView {
                PriceView()
            }
            if uiManager.showPriceOptionOnHome {
                priceOptionsOnHome
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        // MARK: - On Appear
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                Task {
                    await priceManager.refresh()
                }
            }
        }
        // MARK: - TapGesture/Refreshable
        .onTapGesture {
            Task {
                await priceManager.refresh()
            }
        }
        .refreshable {
            Task {
                await priceManager.refresh()
            }
        }
        // MARK: - Background
        .background {
            priceColor.ignoresSafeArea(.all)
        }
        // MARK: - Toolbars
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(
                    destination: Settings()
                        .environmentObject(uiManager)
                        .environmentObject(priceManager)
                ) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .sheet(isPresented: $uiManager.activatePriceHeightModal) {
            PriceHeightModal()
                .presentationDetents(
                    [
                        .fraction(0.2)
                    ]
                )
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $uiManager.activateLimiterModal) {
            PriceLimiterModal()
                .presentationDetents(
                    [
                        .fraction(0.8),
                        .fraction(0.2)
                    ],
                    selection: $uiManager.limiterDetent
                )
                .presentationDragIndicator(.visible)
        }
    }
    
    private var priceOptionsOnHome: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(priceManager.comEdPriceOption.rawValue)
                    .font(.system(size: 14, design: .monospaced))
                    .bold()
            }
            .padding(.horizontal)
        }
    }
}


#Preview {
    @Previewable @StateObject var priceManager = PriceManager()
    @Previewable @StateObject var uiManager = UIManager()
    @Previewable @StateObject var liveActivitiesStart = LiveActivitesManager()
    
    NavigationStack {
        Home()
            .environmentObject(priceManager)
            .environmentObject(uiManager)
            .environmentObject(liveActivitiesStart)
    }
}
