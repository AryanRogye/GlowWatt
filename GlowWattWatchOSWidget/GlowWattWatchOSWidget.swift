//
//  GlowWattWatchOSWidget.swift
//  GlowWattWatchOSWidget
//
//  Created by Aryan Rogye on 5/29/25.
//

import WidgetKit
import SwiftUI
import AppIntents

@main
struct GlowWattWatchOSWidget: Widget {
    let kind: String = "GlowWattWatchOSWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent:  GlowWattAppIntent.self,
            provider: Provider(),
        ) { entry in
            GlowWattWatchOSWidgetView(
                entry: entry
            )
            .containerBackground(
                .fill.tertiary,
                for: .widget
            )
        }
        .configurationDisplayName("GlowWatt Price")
        .description("Live ComEd energy price")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
            .accessoryCorner,
        ])
    }
}

#Preview(as: .accessoryRectangular) {
    GlowWattWatchOSWidget()
} timeline: {
    GlowWattInfo(date: .now, price: 1.0, hideDate: false)
    GlowWattInfo(date: .now, price: 5.0, hideDate: false)
    GlowWattInfo(date: .now, price: 10.0, hideDate: false)
}

#Preview(as: .accessoryInline) {
    GlowWattWatchOSWidget()
} timeline: {
    GlowWattInfo(date: .now, price: 1.0, hideDate: false)
    GlowWattInfo(date: .now, price: 5.0, hideDate: false)
    GlowWattInfo(date: .now, price: 10.0, hideDate: false)
}

#Preview(as: .accessoryCircular) {
    GlowWattWatchOSWidget()
} timeline: {
    GlowWattInfo(date: .now, price: 1.0, hideDate: false)
    GlowWattInfo(date: .now, price: 5.0, hideDate: false)
    GlowWattInfo(date: .now, price: 10.0, hideDate: false)
}

#Preview(as: .accessoryCorner) {
    GlowWattWatchOSWidget()
} timeline: {
    GlowWattInfo(date: .now, price: 1.0, hideDate: false)
    GlowWattInfo(date: .now, price: 5.0, hideDate: false)
    GlowWattInfo(date: .now, price: 10.0, hideDate: false)
}
