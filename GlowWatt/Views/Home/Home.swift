//
//  Home.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI

struct Home: View {
    
    @Environment(\.scenePhase) var scenePhase
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
    
    @State private var priceFetchTask : Task<Void, Never>? = nil
    @State private var didHandleInitialScenePhase = false
    @State private var isRefreshing = false
    
    var priceColor: Color {
        if let price = priceManager.price {
            switch price {
            case ..<4:
                return Color(.systemGreen)
            case 4..<8:
                return Color(.systemYellow)
            default:
                return Color(.systemRed)
            }
        }
        return Color(.systemGray)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        // MARK: - Scene Change Fetch
        /// When Changed from background/incative to active only then refresh
        .onChange(of: scenePhase) { lastValue, value in
            if !didHandleInitialScenePhase {
                didHandleInitialScenePhase = true
                return
            }
            if value == .active && (lastValue == .background || lastValue == .inactive) {
                startRefresh()
            }
        }
        // MARK: - Initial Data Fetch
        .onAppear {
            startRefresh()
        }
        .onDisappear {
            priceFetchTask?.cancel()
            priceFetchTask = nil
        }
        
        // MARK: - TapGesture/Refreshable
        .onTapGesture { startRefresh() }
        
        .refreshable {
            startRefresh()
            await priceFetchTask?.value
        }

        // MARK: - Background
        .onPressingChanged { point in
            if uiManager.priceTapAnimation == .none { return }
            if let point {
                origin = point
                counter += 1
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink {
                    Settings()
                        .environmentObject(uiManager)
                        .environmentObject(priceManager)
                        .environment(onboardingManager)
                } label: {
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
    
    @MainActor
    private func startRefresh() {
        if isRefreshing { return }
        isRefreshing = true
        
        priceFetchTask?.cancel()
        priceFetchTask = Task { @MainActor in
            defer {
                isRefreshing = false
                priceFetchTask = nil
            }
            await priceManager.refresh()
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
