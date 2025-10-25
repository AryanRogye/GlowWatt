//
//  Home.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI

struct Home: View {
    
    @Environment(OnboardingManager.self) var onboardingManager
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager
    @EnvironmentObject var liveActivitesManager: LiveActivitesManager
    
    @State private var origin: CGPoint = .zero
    @State private var counter: Int = 0
    
    @State private var amplitude: Double = 10
    @State private var frequency: Double = 15
    @State private var decay: Double = 8
    @State private var speed: Double = 2000
    
    
    
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
            priceColor.ignoresSafeArea()
            priceColor.ignoresSafeArea()
                .modifier(
                    RippleEffect(
                        shouldActivate: uiManager.shouldUseWave,
                        trigger: counter, origin: origin,
                        amplitude: amplitude, frequency: frequency,
                        decay: decay, speed: speed
                    )
                )

            ScrollView {
                PriceView()
                    .modifier(
                        RippleEffect(
                            shouldActivate: uiManager.shouldUseWave,
                            trigger: counter, origin: origin,
                            amplitude: amplitude, frequency: frequency,
                            decay: decay, speed: speed
                        )
                    )
            }
            .overlay {
                if uiManager.showPriceOptionOnHome {
                    priceOptionsOnHome
                }
            }
            Toolbar()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        // MARK: - Initial Data Fetch
        .task {
            await priceManager.refresh()
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
        .onPressingChanged { point in
            if uiManager.priceTapAnimation == .none { return }
            if let point {
                origin = point
                counter += 1
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
    
    @Previewable @State var onboardingManager = OnboardingManager()
    @Previewable @StateObject var priceManager = PriceManager()
    @Previewable @StateObject var uiManager = UIManager()
    @Previewable @StateObject var liveActivitiesStart = LiveActivitesManager()
    
    NavigationStack {
        NavigationStack {
            Home()
                .environmentObject(priceManager)
                .environmentObject(uiManager)
                .environmentObject(liveActivitiesStart)
                .environment(onboardingManager)
        }
    }
}
