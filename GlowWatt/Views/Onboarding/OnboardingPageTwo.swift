//
//  OnboardingPageTwo.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import SwiftUI

struct OnboardingPageTwo: View {
    
    @State private var titleAppear = false
    @State private var smallDescriptionAppear = false
    @State private var legendSwatchAppear = false
    @State private var textAppear = false
    @State private var demoButtonAppear = false
    
    @Binding var currentPage: Int

    var body: some View {
        VStack {
            // MARK: - Title
            VStack(spacing: 6) {
                Text("How I use")
                Text("GlowWatt")
            }
            .font(.system(size: 46, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .padding(.top, 32)
            .foregroundStyle(titleAppear ? .white : .black)
            .offset(y: titleAppear ? 0 : 10)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: titleAppear)
            
            // MARK: - Description
            Text("3 Colors To Look At")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundStyle(smallDescriptionAppear ? .white.opacity(0.8) : .black)
                .offset(y: smallDescriptionAppear ? 0 : 10)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: smallDescriptionAppear)
            
                .padding(.top)
            
            // MARK: - Colors
            HStack(spacing: 16) {
                LegendSwatch(color: .comfySystemGreen,
                             title: "Green",
                             note: "Good to go")
                LegendSwatch(color: .comfySystemYellow,
                             title: "Yellow",
                             note: "If I really have to")
                LegendSwatch(color: .comfySystemRed,
                             title: "Red",
                             note: "I'm putting this off")
            }
            .frame(height: 120)
            .opacity(legendSwatchAppear ? 1 : 0)
            .offset(y: legendSwatchAppear ? 0 : 10)
            .animation(.spring(response: 0.6, dampingFraction: 0.85), value: legendSwatchAppear)
            
            // MARK: - List
            VStack(spacing: 12) {
                ForEach(Array(["Laundry", "EV Charging", "Dishwasher", "3D Printer"].enumerated()), id: \.offset) { index, item in
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
            if newValue == 1 {
                // Reset then animate
                titleAppear = false
                smallDescriptionAppear = false
                legendSwatchAppear = false
                textAppear = false
                demoButtonAppear = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    titleAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    smallDescriptionAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    legendSwatchAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    textAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    demoButtonAppear = true
                }
                
            } else {
                titleAppear = false
                smallDescriptionAppear = false
                legendSwatchAppear = false
                textAppear = false
                demoButtonAppear = false
            }
        }
        .onAppear {
            if currentPage == 1 {
                titleAppear = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { smallDescriptionAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { legendSwatchAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { textAppear = true
                    textAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { textAppear = true
                    demoButtonAppear = true
                }
            }
        }
    }
}

private struct LegendSwatch: View {
    let color: Color
    let title: String
    let note: String
    
    var body: some View {
        VStack(spacing: 10) {
            // the color tile
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.gradient)
                .frame(width: 86, height: 64)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.25), radius: 8, y: 2)
                .accessibilityHidden(true)
            
            // labels
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(note)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity) // columns balance evenly
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(note)")
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingPageTwo(currentPage: .constant(1))
    }
}
