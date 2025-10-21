//
//  OnboardingPageThree.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import SwiftUI

struct OnboardingPageThree: View {
    
    @State private var titleAppear = false
    @State private var subtitleAppear = false
    @State private var deviceCardsAppear = false
    @State private var textAppear = false
    
    @Binding var currentPage: Int

    var body: some View {
        VStack {
            // Title
            VStack(spacing: 6) {
                Text("Widgets on")
                Text("Watch & iPhone")
            }
            .font(.system(size: 46, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .padding(.top, 32)
            .foregroundStyle(titleAppear ? .white : .black)
            .offset(y: titleAppear ? 0 : 10)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: titleAppear)
            
            Text("Always visible.")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundStyle(subtitleAppear ? .white.opacity(0.8) : .black)
                .offset(y: subtitleAppear ? 0 : 10)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: subtitleAppear)
                .padding(.top)
            
            // Device Cards
            HStack(spacing: 20) {
                DeviceCard(
                    icon: "applewatch",
                    title: "Watch",
                    gradient: LinearGradient(
                        colors: [Color(red: 0.2, green: 0.5, blue: 1.0), Color(red: 0.1, green: 0.3, blue: 0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                DeviceCard(
                    icon: "iphone",
                    title: "iPhone",
                    gradient: LinearGradient(
                        colors: [Color(red: 0.9, green: 0.3, blue: 0.5), Color(red: 0.7, green: 0.2, blue: 0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .frame(height: 140)
            .padding(.horizontal)
            .opacity(deviceCardsAppear ? 1 : 0)
            .offset(y: deviceCardsAppear ? 0 : 20)
            .animation(.spring(response: 0.6, dampingFraction: 0.85), value: deviceCardsAppear)
            .padding(.top, 8)
            
            VStack(spacing: 12) {
                ForEach(Array(["Keep widget on Home Screen", "Add to Watch face", "Glance at rate instantly"].enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(.white.opacity(0.9))
                            .frame(width: 6, height: 6)
                        
                        Text(item)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .opacity(textAppear ? 1 : 0)
                    .offset(y: textAppear ? 0 : 20)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                        value: textAppear
                    )
                }
            }
            .padding(.top, 64)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onChange(of: currentPage) { oldValue, newValue in
            if newValue == 2 {
                // Reset then animate
                titleAppear = false
                subtitleAppear = false
                deviceCardsAppear = false
                textAppear = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    titleAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    subtitleAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    deviceCardsAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    textAppear = true
                }
            } else {
                titleAppear = false
                subtitleAppear = false
                deviceCardsAppear = false
                textAppear = false
            }
        }
        .onAppear {
            if currentPage == 2 {
                titleAppear = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { subtitleAppear = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { deviceCardsAppear = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { textAppear = true }
            }
        }
    }
}

private struct DeviceCard: View {
    let icon: String
    let title: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon container
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(gradient)
                .frame(width: 100, height: 80)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 12, y: 4)
            
            // Label
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) widget")
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingPageThree(currentPage: .constant(2))
    }
}
