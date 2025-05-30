//
//  GlowWattWidget.swift
//  GlowWattWidget
//
//  Created by Aryan Rogye on 5/23/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), price: 0.0)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), price: 0.0)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let fetchedPrice = await API.fetchComEdPrice() ?? 0.0
        AppStorage.setPrice(fetchedPrice)
        AppStorage.setLastUpdated()
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, price: fetchedPrice)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .after(currentDate.addingTimeInterval(1800)))
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let price : Double
}

struct GlowWattWidgetEntryView : View {
    var entry: Provider.Entry
    
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
    
    @Environment(\.widgetFamily) var family
    
    private var fontSize: CGFloat {
        switch family {
        case .systemSmall:
            return 20
        case .systemMedium:
            return 28
        case .systemLarge:
            return 36
        case .systemExtraLarge:
            return 36
        default:
            return 20
        }
    }
    
    var body: some View {
        ZStack {
            priceColor.ignoresSafeArea(.all)
            VStack(alignment: .leading) {
                Spacer()
                
                HStack {
                    Text("\(entry.price, specifier: "%.2f")")
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 2)
                    Spacer()
                }
                
                Spacer()
                
                if family == .systemSmall {
                    systemSmallView
                } else {
                    systemMediumView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "glowwatt://refresh"))
    }
    
    private var systemSmallView: some View {
        VStack {
            HStack {
                Text("Last updated")
                    .font(.system(size: fontSize * 0.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }
                
            HStack {
                Text(formattedDate)
                    .font(.system(size: fontSize * 0.6, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
            }
        }
    }
    
    private var systemMediumView: some View {
        HStack {
            Text("Last updated")
                .font(.system(size: fontSize * 0.5, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(formattedDate)
                .font(.system(size: fontSize * 0.5, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct GlowWattWidgetHomeScreen: Widget {
    let kind: String = "GlowWattWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GlowWattWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    entry.price < 4 ? Color.green :
                    entry.price < 8 ? Color.yellow :
                    Color.red
                }
        }
    }
}

#Preview(as: .systemSmall) {
    GlowWattWidgetHomeScreen()
} timeline: {
    SimpleEntry(date: .now, price: 1.3)
    SimpleEntry(date: .now, price: -1.10)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .systemMedium) {
    GlowWattWidgetHomeScreen()
} timeline: {
    SimpleEntry(date: .now, price: 1.3)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .systemLarge) {
    GlowWattWidgetHomeScreen()
} timeline: {
    SimpleEntry(date: .now, price: 1.3)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .systemExtraLarge) {
    GlowWattWidgetHomeScreen()
} timeline: {
    SimpleEntry(date: .now, price: 1.3)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}



