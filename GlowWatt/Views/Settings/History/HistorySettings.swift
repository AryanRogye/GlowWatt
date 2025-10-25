//
//  HistorySettings.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/25/25.
//

import SwiftUI

// MARK: - History Settings
struct HistorySettings: View {
    
    var viewHistoryID = "viewHistoryAnimation"
    var maxHistoryID = "maxHistoryID"
    
    @Namespace var histNM
    @Namespace var maxHistNM
    
    var body: some View {
        Section("History") {
            NavigationLink {
                HistoryView(for: HistoryViewState.currentHistory)
                    .navigationTransition(.zoom(sourceID: viewHistoryID, in: histNM))
            } label: {
                Text("View History")
                    .overlay {
                        Color.clear
                            .matchedTransitionSource(id: viewHistoryID, in: histNM)
                    }
            }
            
            NavigationLink {
                HistoryView(for: HistoryViewState.historyCount)
                    .navigationTransition(.zoom(sourceID: maxHistoryID, in: maxHistNM))
            } label: {
                Text("Max History Count")
                    .overlay {
                        Color.clear
                            .matchedTransitionSource(id: maxHistoryID, in: maxHistNM)
                    }
            }
        }
    }
}
