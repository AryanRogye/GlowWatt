//
//  ContentView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 5/23/25.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(PriceProvider())
        .environmentObject(UIManager())
}
