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
        ScrollView {
            PriceView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        // MARK: - On Appear
        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                priceManager.refresh()
//            }
        }
        // MARK: - TapGesture/Refreshable
        .onTapGesture {
            priceManager.refresh()
        }
        .refreshable {
            priceManager.refresh()
        }
        // MARK: - Background
        .background {
            priceColor.ignoresSafeArea(.all)
        }
        // MARK: - Toolbars
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: Settings()) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(Color.primary)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if liveActivitesManager.hasStarted {
                    Button(action: {
                        liveActivitesManager.stopLiveActivity()
                    }) {
                        Text("Stop Live Activity")
                    }
                } else {
                    Button(action: {
                        uiManager.toggleLimiterModal(with: priceManager.price)
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            
        }
        
        //        .toolbar {
        //            ToolbarItem(placement: .primaryAction) {
        //                Button(action: {
        //                    started = false
        //                    liveActivitesManager.stopLiveActivity()
        //                }) {
        //                    Image(systemName: "xmark")
        //                        .foregroundStyle(Color.primary)
        //                }
        //            }
        //        }
        
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
