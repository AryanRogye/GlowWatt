//
//  GlowWattWatchOSWidgetView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 2/6/26.
//

import WatchKit
import WidgetKit
import SwiftUI

struct GlowWattInfo: TimelineEntry {
    let date: Date
    let price: Double
    let hideDate : Bool
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(
        in context: Context
    ) -> GlowWattInfo {
        GlowWattInfo(
            date: Date(),
            price: 0.0,
            hideDate: false
        )
    }
    
    func snapshot(
        for configuration: GlowWattAppIntent,
        in context: Context
    ) async -> GlowWattInfo {
        GlowWattInfo(
            date: Date(),
            price: 0.0,
            hideDate: configuration.hideDate
        )
    }
    
    func timeline(for configuration: GlowWattAppIntent, in context: Context) async -> Timeline<GlowWattInfo> {
        let now = Date()
        let fetchedPrice = await API.fetchComEdPrice() ?? 0.0
        await MainActor.run {
            AppStorage.setPrice(fetchedPrice)
            AppStorage.setLastUpdated(now)
            AppStorage.addPriceToHistory(fetchedPrice, date: now)
        }
        let entry = GlowWattInfo(
            date: now,
            price: fetchedPrice,
            hideDate: configuration.hideDate
        )
        let timeline = Timeline(
            entries: [entry],
            policy: .after(now.addingTimeInterval(1800))
        )
        
        return timeline
    }
    
    func recommendations() -> [AppIntentRecommendation<GlowWattAppIntent>] {
        [
            AppIntentRecommendation(
                intent: GlowWattAppIntent(),
                description: "Default"
            )
        ]
    }
}

// MARK: - AccessoryRectangleView
struct AccessoryRectangleView: View {
    var entry: Provider.Entry
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(entry.price, specifier: "%.2f")¢")
                .widgetAccentable()
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundStyle(.white)
                .font(.system(size: 30, weight: .medium))
            
            if !entry.hideDate {
                Text(relativeTimestamp(AppStorage.getLastUpdated()))
                    .widgetAccentable()
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.priceColor(entry.price), lineWidth: 2)
        }
    }
    
    private func relativeTimestamp(_ date: Date?) -> String {
        date?.formatted(
            Date.RelativeFormatStyle(presentation: .named, unitsStyle: .abbreviated)
        ) ?? "Never"
    }
}

// MARK: - AccessoryInlineView
struct AccessoryInlineView: View {
    let price: Double
    var body: some View {
        Text("\(price, specifier: "%.2f")¢")
            .widgetAccentable()
            .font(.headline)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
}

// MARK: - AccessoryCircularView
struct AccessoryCircularView: View {
    
    let price: Double
    let fontWeight: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        Circle()
            .fill(.clear)
            .strokeBorder(Color.priceColor(price), lineWidth: lineWidth)
            .overlay {
                Text("\(price, specifier: "%.2f")¢")
                    .widgetAccentable()
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .font(.system(size: fontWeight))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .padding(1)
    }
}

// MARK: - Main
struct GlowWattWatchOSWidgetView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        
        switch family {
        case .accessoryRectangular:
            AccessoryRectangleView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(price: entry.price)
        case .accessoryCircular:
            AccessoryCircularView(price: entry.price, fontWeight: 12, lineWidth: 4)
        case .accessoryCorner:
            AccessoryCircularView(price: entry.price, fontWeight: 10, lineWidth: 2)
        default:
            EmptyView()
        }
    }
}


extension Color {
    
    static let comfySystemGreen  = Color(red: 52/255,  green: 199/255, blue: 89/255)   // #34C759
    static let comfySystemRed    = Color(red: 255/255, green: 59/255,  blue: 48/255)   // #FF3B30
    static let comfySystemYellow = Color(red: 255/255, green: 204/255, blue: 0/255)    // #FFCC00
    
    static func priceColor(_ price: Double) -> Color {
        switch price {
        case ..<4:
            return .comfySystemGreen
        case 4..<8:
            return .comfySystemYellow
        default:
            return .comfySystemRed
        }
    }
}
