//
//  IssuesSettings.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/25/25.
//

import SwiftUI

// MARK: - Issues Settings
struct IssuesSettings: View {
    
    var id = "submitFeedbackAnimation"
    @Namespace var nm
    @State private var showScreen = false
    
    var body: some View {
        Section("Issues") {
            HStack {
                Text("Submit Feedback")
                Spacer()
            }
            .matchedTransitionSource(id: id, in: nm)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                showScreen = true
            }
            .fullScreenCover(isPresented: $showScreen) {
                NavigationStack {
                    SubmitFeedbackView()
                        .navigationTransition(.zoom(sourceID: id, in: nm))
                        .toolbarCancel($showScreen)
                }
            }
        }
    }
}
