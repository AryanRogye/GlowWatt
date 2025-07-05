//
//  priceHeightModal.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/4/25.
//

import SwiftUI

struct priceHeightModal: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var uiManager: UIManager
    
    @State private var price: CGFloat = 0
    @State private var savePressed: Bool = false
    
    var body: some View {
        VStack {
            dismissModalView
                .padding([.horizontal,.top], 20)
            sliderView()
            
            Spacer()
        }
        .onAppear {
            let minHeight = 200.0
            let screenHeight = UIScreen.main.bounds.height
            let maxHeight = screenHeight - 100
            
            price = min(max(uiManager.priceHeight, minHeight), maxHeight)
        }
        .onDisappear {
            if !savePressed {
                uiManager.priceHeight = price
            } else {
                savePressed = false
            }
        }
    }
    
    private func sliderView() -> some View {
        let minHeight = 200.0
        let screenHeight = UIScreen.main.bounds.height
        let maxHeight = Double(screenHeight - 100)
        
        return VStack {
            Slider(
                value: Binding(
                    get: { Double(uiManager.priceHeight) },
                    set: { uiManager.priceHeight = CGFloat($0) }
                ),
                in: minHeight...maxHeight,
                step: 1
            )
            
            Text("Height: \(Int(uiManager.priceHeight))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    private var dismissModalView: some View {
        HStack {
            Button(action: {
                uiManager.priceHeight = price
                dismissModal()
            }) {
                Text("Dismiss")
                    .font(.headline)
                    .foregroundColor(Color(.systemGray))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            Button(action: {
                savePressed = true
                uiManager.savePriceHeight()
                dismissModal()
            }) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(Color(.systemGray))
            }
        }
    }
    
    private func dismissModal() {
        dismiss()
    }
}


#Preview {
    VStack {
        
    }
    .sheet(isPresented: .constant(true)) {
        priceHeightModal()
            .environmentObject(UIManager())
            .presentationDetents([.fraction(0.2)])
            .presentationDragIndicator(.hidden)
    }
}
