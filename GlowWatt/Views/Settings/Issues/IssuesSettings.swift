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
    
    var body: some View {
        Section("Issues") {
            NavigationLink() {
                SubmitFeedbackView()
                    .navigationTransition(.zoom(sourceID: id, in: nm))
            } label: {
                Text("Submit Feedback")
                    .overlay {
                        Color.clear
                            .matchedTransitionSource(id: id, in: nm)
                    }
            }
        }
    }
}
