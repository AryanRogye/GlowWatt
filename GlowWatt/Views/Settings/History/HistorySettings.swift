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
    
    @State private var showViewHistory = false
    @State private var showMaxHistoryCount = false
    
    var body: some View {
        Section("History") {
            HStack {
                Text("View History")
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                showMaxHistoryCount = true
            }
            .matchedTransitionSource(id: viewHistoryID, in: histNM)
            .fullScreenCover(isPresented: $showViewHistory) {
                NavigationStack {
                    HistoryView(for: HistoryViewState.currentHistory)
                        .navigationTransition(.zoom(sourceID: viewHistoryID, in: histNM))
                        .toolbarCancel($showViewHistory)
                }
            }
            
            HStack {
                Text("Max History Count")
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                showMaxHistoryCount = true
            }
            .matchedTransitionSource(id: maxHistoryID, in: maxHistNM)
            .fullScreenCover(isPresented: $showMaxHistoryCount) {
                NavigationStack {
                    HistoryView(for: HistoryViewState.historyCount)
                        .navigationTransition(.zoom(sourceID: maxHistoryID, in: maxHistNM))
                        .toolbarCancel($showMaxHistoryCount)
                }
            }
        }
    }
}
