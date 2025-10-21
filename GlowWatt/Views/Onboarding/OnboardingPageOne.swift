//
//  OnboardingPageOne.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import SwiftUI

struct OnboardingPageOne: View {
    
    @State private var titleAppear = false
    @State private var subtitleAppear = false
    @State private var textAppear = false
    
    @Binding var currentPage: Int

    var body: some View {
        VStack {
            VStack {
                Text("Welcome To")
                Text("GlowWatt")
            }
            .font(.system(size: 50, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .padding(.top, 32)
            .foregroundStyle(titleAppear ? .white : .black)
            .offset(y: titleAppear ? 0 : 10)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: titleAppear)
            
            Text("Know your power.")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundStyle(subtitleAppear ? Color.comfySystemGreen : .black)
                .padding(.top)
                .offset(y: subtitleAppear ? 0 : 10)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: subtitleAppear)
            
            VStack {
                Text("GlowWatt helps you see when")
                Text("energy is cheapest, so you can")
                Text("make smarter choices")
                Text("without changing your routine.")
            }
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundStyle(textAppear ? .white.opacity(0.9) : Color.black)
            .padding(.top)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: textAppear)
            Spacer()
            
        }
        .frame(alignment: .top)
        .onChange(of: currentPage) { oldValue, newValue in
            if newValue == 0 {
                // Reset then animate
                titleAppear = false
                subtitleAppear = false
                textAppear = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    titleAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    subtitleAppear = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    textAppear = true
                }
            } else {
                titleAppear = false
                subtitleAppear = false
                textAppear = false
            }
        }
        .onAppear {
            if currentPage == 0 {
                titleAppear = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { subtitleAppear = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { textAppear = true }
            }
        }
    }
}

