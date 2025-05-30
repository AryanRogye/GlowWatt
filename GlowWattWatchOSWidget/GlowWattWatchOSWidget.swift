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

struct GlowWattWatchOSWidgetEntryView : View {
    var entry: Provider.Entry
    
    var priceColor: Color {
        switch entry.price {
        case 0..<4:
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
                Text("Current Price: $\(entry.price, specifier: "%.2f")")
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .font(.system(size: 35, weight: .medium))
                
                Spacer()
                
                HStack {
                    Text("Last updated")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                }
                
                HStack {
                    Text(formattedDate)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
            }
            .padding()
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
            .accessoryCircular
        ])
    }
}

#Preview(as: .accessoryRectangular) {
    GlowWattWatchOSWidget()
} timeline: {
    SimpleEntry(date: .now, price: 1.3)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}
