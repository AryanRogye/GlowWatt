//
//  SubmitFeedbackView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 7/5/25.
//

import SwiftUI
import SafariServices


struct SubmitFeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var feedbackType: FeedbackType = .bug
    @State private var feedbackDescription: String = ""
    @State private var feedbackText: String = ""
    @State private var isSubmitting: Bool = false
    
    @State private var safariURL: URL?
    @State private var showSafari: Bool = false
    
    @FocusState private var feedBackInFocus: Bool
    
    enum FeedbackType: String, CaseIterable {
        case bug = "Bug Report"
        case feature = "Feature Request"
        case general = "General Feedback"
        
        var icon: String {
            switch self {
            case .bug: return "exclamationmark.triangle"
            case .feature: return "lightbulb"
            case .general: return "bubble.left.and.bubble.right"
            }
        }
    }
    
    private var placeholderText: String {
        switch feedbackType {
        case .bug:
            return "Please describe the bug, including steps to reproduce it..."
        case .feature:
            return "Describe the feature you'd like to see added..."
        case .general:
            return "Share your thoughts, suggestions, or feedback..."
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                feedbackTypeView
                
                TextField("Description", text: $feedbackDescription)
                
                Section(header: Text("Feedback")) {
                    TextEditor(text: $feedbackText)
                        .focused($feedBackInFocus)
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .overlay{
                            if !feedBackInFocus {
                                Text(placeholderText)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .opacity(feedbackText.isEmpty ? 1 : 0)
                            }
                        }
                }
                
                Section {
                    Button(action: {
                        let encodedLabel = feedbackType.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "feedback"
                        let encodedTitle = feedbackDescription.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Feedback"
                        
                        // Replace this part:
                        let deviceInfo = """
                        Device Info:
                                - iOS Version: \(UIDevice.current.systemVersion)
                                - App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                                - Device: \(UIDevice.current.model)
                            ---
                                \(feedbackText)
                        """
                        
                        let encodedBody = deviceInfo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        
                        let urlString = "https://github.com/aryanrogye/GlowWatt/issues/new?labels=\(encodedLabel)&title=\(encodedTitle)&body=\(encodedBody)"
                        
                        safariURL = URL(string: urlString)
                        showSafari = true
                    }) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit Feedback")
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(feedbackDescription.isEmpty || feedbackText.isEmpty)
                }
                
                Section(footer: Text("You’ll be redirected to GitHub Issues to finish submitting feedback. A GitHub account is required to post. Sorry for any inconvenience!")) {
                }
            }
            .navigationTitle("Submit Feedback")
        }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
    }
    
    private var feedbackTypeView: some View {
        List {
            Picker("Type", selection: $feedbackType) {
                ForEach(FeedbackType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
        }
    }
}


struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}


#Preview {
    SubmitFeedbackView()
}
