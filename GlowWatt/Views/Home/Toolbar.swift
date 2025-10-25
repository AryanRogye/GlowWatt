//
//  Toolbar.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/25/25.
//

import SwiftUI

struct Toolbar: View {
    
    @Environment(OnboardingManager.self) var onboardingManager
    @EnvironmentObject var priceManager : PriceManager
    @EnvironmentObject var uiManager: UIManager
    @EnvironmentObject var liveActivitesManager: LiveActivitesManager
    
    @Namespace var nm
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if #available(iOS 26.0, *) {
                    NavigationLink {
                        Settings(namespace: nm)
                            .environmentObject(uiManager)
                            .environmentObject(priceManager)
                            .environment(onboardingManager)
                            .navigationTransition(.zoom(sourceID: "zoom", in: nm))
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .foregroundStyle(Color.primary)
                            .frame(width: 32, height: 32)
                            .padding(8)
                            .overlay {
                                Color.clear
                                    .matchedTransitionSource(id: "zoom", in: nm)
                            }
                    }
                    .glassEffect(.regular.interactive())
                } else {
                    NavigationLink {
                        Settings(namespace: nm)
                            .environmentObject(uiManager)
                            .environmentObject(priceManager)
                            .environment(onboardingManager)
                            .navigationTransition(.zoom(sourceID: "zoom", in: nm))
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.primary)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Color.clear
                                    .matchedTransitionSource(id: "zoom", in: nm)
                            }
                    }
                    .matchedTransitionSource(id: "zoom", in: nm)
                    .background { Circle().fill(.ultraThinMaterial) }
                    .buttonStyle(.plain)
                }
            }
            .padding([.horizontal, .top])
            
            Spacer()
        }
    }
}
