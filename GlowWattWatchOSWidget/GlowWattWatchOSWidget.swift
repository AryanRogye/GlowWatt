//
//  GlowWattWatchOSWidget.swift
//  GlowWattWatchOSWidget
//
//  Created by Aryan Rogye on 5/29/25.
//

import WidgetKit
import SwiftUI

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
            AppStorage.setPrice(fetchedPrice)
            AppStorage.setLastUpdated()
            
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

struct AnyShape: Shape {
    private let pathBuilder: (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        self.pathBuilder = shape.path(in:)
    }
    
    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

struct GlowWattWatchOSWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var priceColor: Color {
        switch entry.price {
        case ..<4:
            return .green
        case 4..<8:
            return .yellow
        default:
            return .red
        }
    }
    
    private var formattedDate: String {
        return AppStorage.getLastUpdated()?.formatted() ?? "Never"
    }

    var body: some View {
        ZStack {
            priceColor.ignoresSafeArea(.all)
            VStack {
                switch family {
                case .accessoryRectangular:
                    accessoryRectangleView
                case .accessoryInline:
                    accessoryInlineView
                case .accessoryCircular:
                    accessoryCircularView
                case .accessoryCorner:
                    accessoryCornerView
                default:
                    EmptyView()
                }
            }
            .padding()
        }
        .containerBackground(priceColor, for: .widget)
        .clipShape(
            family == .accessoryCircular || family == .accessoryCorner
                ? AnyShape(Circle())
                : AnyShape(RoundedRectangle(cornerRadius: 10))
        )
        .padding(1)
        .widgetURL(URL(string: "glowwatt://refresh"))
    }
    
    private var accessoryCornerView: some View {
        Text("\(entry.price, specifier: "%.2f")¢")
            .widgetAccentable()
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .foregroundStyle(.black)
            .font(.system(size: 7))
    }

    private var accessoryCircularView: some View {
        Text("\(entry.price, specifier: "%.2f")¢")
            .widgetAccentable()
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .foregroundStyle(.black)
            .font(.system(size: 8))
    }
    
    private var accessoryInlineView: some View {
        Text("Current Price: \(entry.price, specifier: "%.2f")¢")
            .widgetAccentable()
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .font(.system(size: 30, weight: .medium))
    }
    
    private var accessoryRectangleView: some View {
        VStack {
            HStack {
                Text("Current Price: \(entry.price, specifier: "%.2f")¢")
                    .widgetAccentable()
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(.black)
                    .font(.system(size: 30, weight: .medium))
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Text("Last updated")
                    .widgetAccentable()
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
            
            HStack {
                Text(formattedDate)
                    .widgetAccentable()
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
            }
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
    SimpleEntry(date: .now, price: 10.3634)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .accessoryInline) {
    GlowWattWatchOSWidget()
} timeline: {
    SimpleEntry(date: .now, price: 10.3634)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .accessoryCircular) {
    GlowWattWatchOSWidget()
} timeline: {
    SimpleEntry(date: .now, price: 10.3634)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .accessoryCorner) {
    GlowWattWatchOSWidget()
} timeline: {
    SimpleEntry(date: .now, price: 10.3634)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}
