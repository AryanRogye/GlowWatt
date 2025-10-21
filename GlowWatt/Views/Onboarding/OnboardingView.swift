//
//  OnboardingView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import SwiftUI

extension Color {
    static let comfySystemGreen  = Color(red: 52.0/255.0,  green: 199.0/255.0, blue: 89.0/255.0)   // #34C759
    static let comfySystemRed    = Color(red: 255.0/255.0, green: 59.0/255.0,  blue: 48.0/255.0)   // #FF3B30
    static let comfySystemYellow = Color(red: 255.0/255.0, green: 204.0/255.0, blue: 0.0/255.0)    // #FFCC00
}


struct OnboardingView: View {
    
    let maxPage = 2
    @State private var selectedPage = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(OnboardingManager.self) var onboardingManager
    
    // Color cycling based on page
    private var currentAccentColor: Color {
        switch selectedPage {
        case 0: return .comfySystemGreen
        case 1: return .comfySystemYellow
        case 2: return .comfySystemRed
        default: return .comfySystemGreen
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $selectedPage) {
                    OnboardingPageOne(currentPage: $selectedPage)
                        .tag(0)
                    OnboardingPageTwo(currentPage: $selectedPage)
                        .tag(1)
                    OnboardingPageThree(currentPage: $selectedPage)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Bottom controls
                VStack(spacing: 20) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0...maxPage, id: \.self) { index in
                            Circle()
                                .fill(selectedPage == index ? currentAccentColor : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.spring(response: 0.3), value: selectedPage)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        if selectedPage > 0 {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedPage -= 1
                                }
                            }) {
                                Text("Back")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        
                        Button(action: {
                            if selectedPage < maxPage {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    selectedPage += 1
                                }
                            } else {
                                // Done with onboarding
                                print("Called Complete")
                                onboardingManager.completeOnboarding()
                                dismiss()
                            }
                        }) {
                            Text(selectedPage == maxPage ? "Get Started" : "Next")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(currentAccentColor)
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
        }
    }
}

#Preview {
    @Previewable @State var onboardingManager = OnboardingManager()
    OnboardingView()
        .environment(onboardingManager)
}
