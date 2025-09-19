//
//  HistoryView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/5/25.
//

import SwiftUI

public enum HistoryViewState {
    case currentHistory
    case historyCount
}

struct HistoryView: View {
    
    let state: HistoryViewState
    
    init(for state: HistoryViewState) {
        self.state = state
    }
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var userPriceManager = UserPricesManager.shared
    
    var body: some View {
        VStack {
            switch state {
            case .currentHistory:
                HistoryCurrentView()
            case .historyCount:
                HistoryCountSlider()
            }
            Spacer()
        }
        .padding()
    }
}
