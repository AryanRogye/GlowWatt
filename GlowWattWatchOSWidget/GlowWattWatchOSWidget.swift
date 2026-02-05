//
//  GlowWattWatchOSWidget.swift
//  GlowWattWatchOSWidget
//
//  Created by Aryan Rogye on 5/29/25.
//

import WidgetKit
import SwiftUI

extension Color {
    static let comfySystemGreen  = Color(red: 52/255,  green: 199/255, blue: 89/255)   // #34C759
    static let comfySystemRed    = Color(red: 255/255, green: 59/255,  blue: 48/255)   // #FF3B30
    static let comfySystemYellow = Color(red: 255/255, green: 204/255, blue: 0/255)    // #FFCC00
}

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), price: 0.0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date(), price: 0.0))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        Task {
            let fetchedPrice = await API.fetchComEdPrice() ?? 0.0
            await MainActor.run {
                AppStorage.setPrice(fetchedPrice)
                AppStorage.setLastUpdated()
            }
            
            let entry = SimpleEntry(date: Date(), price: fetchedPrice)
            let currentDate = Date()
            let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(1800)))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let price: Double
}

struct GlowWattWatchOSWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var priceColor: Color {
        switch entry.price {
        case ..<4:
            return .comfySystemGreen
        case 4..<8:
            return .comfySystemYellow
        default:
            return .comfySystemRed
        }
    }
    
    // MARK: - Time Stamp
    private var relativeTimestamp : String {
        
        AppStorage.getLastUpdated()?.formatted(
            Date.RelativeFormatStyle(presentation: .named, unitsStyle: .abbreviated)
        ) ?? "Never"
        
    }
    
    var body: some View {
        
        switch family {
        case .accessoryRectangular:
            accessoryRectangleView
        case .accessoryInline:
            accessoryInlineView
        case .accessoryCircular:
            accessoryCircularView(fontWeight: 12,lineWidth: 4)
        case .accessoryCorner:
            accessoryCircularView(fontWeight: 10, lineWidth: 2)
        default:
            EmptyView()
        }
    }
    
    private func accessoryCircularView(fontWeight: CGFloat, lineWidth: CGFloat) -> some View {
        Circle()
            .fill(.clear)
            .strokeBorder(priceColor, lineWidth: lineWidth)
            .overlay {
                Text("\(entry.price, specifier: "%.2f")¢")
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
    
    private var accessoryInlineView: some View {
        Text("\(entry.price, specifier: "%.2f")¢")
            .widgetAccentable()
            .font(.headline)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
    
    private var accessoryRectangleView: some View {
        VStack(alignment: .leading) {
            Text("\(entry.price, specifier: "%.2f")¢")
                .widgetAccentable()
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .foregroundStyle(.white)
                .font(.system(size: 30, weight: .medium))
            
            Text(relativeTimestamp)
                .widgetAccentable()
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(priceColor, lineWidth: 2)
        }
    }
}

@main
struct GlowWattWatchOSWidget: Widget {
    let kind: String = "GlowWattWatchOSWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GlowWattWatchOSWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
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
    SimpleEntry(date: .now, price: 1.0)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .accessoryInline) {
    GlowWattWatchOSWidget()
} timeline: {
    SimpleEntry(date: .now, price: 1.0)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .accessoryCircular) {
    GlowWattWatchOSWidget()
} timeline: {
    SimpleEntry(date: .now, price: 1.0)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .accessoryCorner) {
    GlowWattWatchOSWidget()
} timeline: {
    SimpleEntry(date: .now, price: 1.0)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}
