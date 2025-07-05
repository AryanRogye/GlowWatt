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
    
    var body: some View {
        NavigationView {
            Form {
                Section("Feedback Type") {
                    Picker("Type", selection: $feedbackType) {
                        ForEach(FeedbackType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                                Spacer()
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }
                
                TextField("Description", text: $feedbackDescription)
                    .padding(.vertical, 6)
                
                Section(header: Text("Feedback")) {
                    TextEditor(text: $feedbackText)
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                Section {
                    Button(action: {
                        let encodedLabel = feedbackType.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "feedback"
                        let encodedTitle = feedbackDescription.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Feedback"
                        let encodedBody = feedbackText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        
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
                }
            }
            .navigationTitle("Submit Feedback")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url)
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
