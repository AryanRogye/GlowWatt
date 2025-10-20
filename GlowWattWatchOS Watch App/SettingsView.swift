//
//  SettingsView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/20/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(WatchOSSettingsModel.self) private var settingsModel
    
    var body: some View {
        List {
            Section("Behavior") {
                NavigationLink {
                    WidgetTapBehaviorSettings()
                } label: {
                    LabeledContent("Widget Tap") {
                        HStack(spacing: 4) {
                            Text(settingsModel.widgetTapBehavior.rawValue)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
    }
}

private struct WidgetTapBehaviorSettings: View {
    @Environment(WatchOSSettingsModel.self) private var model
    
    var body: some View {
        List {
            ForEach(WidgetTapBehavior.allCases, id: \.self) { behavior in
                HStack {
                    Text(behavior.rawValue.capitalized)
                    Spacer()
                    if behavior == model.widgetTapBehavior {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.tint)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    model.widgetTapBehavior = behavior
                }
            }
        }
        .navigationTitle("Tap Behavior")
    }
}
