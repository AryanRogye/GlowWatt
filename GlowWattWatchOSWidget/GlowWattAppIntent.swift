//
//  GlowWattAppIntent.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 2/6/26.
//

import AppIntents

struct GlowWattAppIntent: WidgetConfigurationIntent {
    static let title : LocalizedStringResource = "GlowWatt Widget Configuration"
    static let description: IntentDescription = "This is an example widget."
    
    @Parameter(title: "Hide Date", default: false)
    var hideDate: Bool
}
