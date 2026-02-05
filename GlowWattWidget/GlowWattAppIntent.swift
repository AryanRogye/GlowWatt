//
//  AppIntent.swift
//  GlowWattWidget
//
//  Created by Aryan Rogye on 5/23/25.
//

import WidgetKit
import AppIntents

struct GlowWattAppIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "GlowWatt Widget Configuration"
    static let description: IntentDescription = "This is an example widget."
    
    @Parameter(title: "Show Reload", default: true)
    var showingButton : Bool
    
    @Parameter(title: "Hide Status On Tint", default: false)
    var hideStatusOnTint: Bool
    
    @Parameter(title: "Hide Date", default: false)
    var hideDate: Bool
}
