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

// MARK: - Helpers
struct PriceFormatted: View {
    
    var entry: Provider.Entry
    var fontSize: CGFloat
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        Text("\(entry.price, specifier: "%.2f")¢")
            .font(.system(size: fontSize, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 2)
            .widgetAccentable()
    }
}

// MARK: - Acessory Circular
struct GlowWattAcessoryCircular: View {
    
    var entry: Provider.Entry
    var fontSize: CGFloat
    
    var body: some View {
        Circle()
            .foregroundStyle(.primary.opacity(0.2))
            .overlay {
                PriceFormatted(entry: entry, fontSize: fontSize)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - MAIN
struct GlowWattWidgetEntryView : View {
    // MARK: - Price Color
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
    
    // MARK: - Font Size
    private var fontSize: CGFloat {
        switch family {
        case .accessoryCircular:
            return 18
        case .accessoryInline:
            return 18
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
    
    // MARK: - Accented Status
    @ViewBuilder
    private var accentedStatus: some View {
        switch priceColor {
        case .green:
            Label {
                Text("Good")
            } icon: {
                Image(systemName: "checkmark.circle.fill")
            }
        case .yellow:
            Label {
                Text("Medium")
            } icon: {
                Image(systemName: "exclamationmark.circle.fill")
            }
        case .red:
            Label {
                Text("Bad")
            } icon: {
                Image(systemName: "xmark.octagon.fill")
            }
        default:
            Label {
                Text("Can't Find")
            } icon: {
                Image(systemName: "questionmark.circle.fill")
            }
        }
    }
    
    // MARK: - Accented Status View
    private func accentedStatusView(
        scale: CGFloat
    ) -> some View {
        accentedStatus
            .font(.system(size: fontSize * scale, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(priceColor.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Date Display
    private func dateDisplay(
        scale: CGFloat,
        updatedOpacity: Double = 0.75,
        timestampOpacity: Double = 0.6
    ) -> some View {
        HStack {
            Text("Updated")
                .font(.system(size: fontSize * scale, weight: .semibold))
                .foregroundColor(.white.opacity(updatedOpacity))
            Spacer()
            
            Text(relativeTimestamp)
                .font(.system(size: fontSize * scale, weight: .bold))
                .foregroundColor(.white.opacity(timestampOpacity))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(priceColor.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
        }
    }
    
    // MARK: - Formatted Date
    private var relativeTimestamp : String {
        
        AppStorage.getLastUpdated()?.formatted(
            Date.RelativeFormatStyle(presentation: .named, unitsStyle: .abbreviated)
        ) ?? "Never"
        
    }
    
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.widgetRenderingMode) private var widgetRenderingMode
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            GlowWattAcessoryCircular(entry: entry, fontSize: fontSize)
                .widgetURL(URL(string: "glowwatt://refresh"))
        case .accessoryInline:
            PriceFormatted(entry: entry, fontSize: fontSize)
                .widgetURL(URL(string: "glowwatt://refresh"))
        default:
            VStack(alignment: .leading) {
                /// No Matter What Price is Left Side
                Spacer()
                
                HStack {
                    PriceFormatted(entry: entry, fontSize: fontSize)
                    Spacer()
                }
                
                Spacer()
                
                if family == .accessoryRectangular {
                    accessoryRectangularView
                }
                if family == .systemSmall {
                    systemSmallView
                }
                if family == .systemMedium {
                    systemMediumView
                }
                if family == .systemLarge {
                    systemMediumView
                }
                if family == .systemExtraLarge {
                    systemMediumView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .widgetURL(URL(string: "glowwatt://refresh"))
            .animation(.spring, value: entry.price)
            .animation(.spring, value: widgetRenderingMode)
        }
    }
    
    // MARK: - Acessory Rectangle
    @ViewBuilder
    private var accessoryRectangularView: some View {
        VStack(alignment: .leading) {
            Text("Last Updated:")
            Text(relativeTimestamp)
        }
        .font(.system(size: fontSize * 0.6, weight: .medium))
        .foregroundColor(.white.opacity(0.6))
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    
    // MARK: - Small View
    private var systemSmallView: some View {
        VStack(spacing: 10) {
            
            dateDisplay(
                scale: 0.6,
                updatedOpacity: 0.75,
                timestampOpacity: 0.6
            )
            
            if widgetRenderingMode == .accented {
                accentedStatusView(scale: 0.6)
            }
        }
    }
    
    // MARK: - Medium View
    private var systemMediumView: some View {
        VStack(alignment: .leading) {
            
            dateDisplay(
                scale: 0.5,
                updatedOpacity: 0.8,
                timestampOpacity: 0.8
            )
            
            if widgetRenderingMode == .accented {
                accentedStatusView(scale: 0.8)
            }
        }
    }
}

struct GlowWattWidgetHomeScreen: Widget {
    let kind: String = "GlowWattWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            GlowWattWidgetEntryView(entry: entry)
                .contentMargins(.zero)
                .containerBackground(for: .widget) {
                    entry.price < 4 ? Color.green :
                    entry.price < 8 ? Color.yellow :
                    Color.red
                }
                .background(.clear)
            
        }
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
        ])
    }
}

#Preview(as: .accessoryCircular) {
    GlowWattWidgetHomeScreen()
} timeline: {
    SimpleEntry(date: .now, price: 1.3)
    SimpleEntry(date: .now, price: -1.10)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}


#Preview(as: .accessoryInline) {
    GlowWattWidgetHomeScreen()
} timeline: {
    SimpleEntry(date: .now, price: 1.3)
    SimpleEntry(date: .now, price: -1.10)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .accessoryRectangular) {
    GlowWattWidgetHomeScreen()
} timeline: {
    SimpleEntry(date: .now, price: 1.3)
    SimpleEntry(date: .now, price: -1.10)
    SimpleEntry(date: .now, price: 5.0)
    SimpleEntry(date: .now, price: 10.0)
}

#Preview(as: .systemSmall) {
    GlowWattWidgetHomeScreen()
} timeline: {
    let now = Date()
    SimpleEntry(date: Calendar.current.date(byAdding: .hour, value: -3, to: now)!, price: 1.3)
    SimpleEntry(date: Calendar.current.date(byAdding: .hour, value: -2, to: now)!, price: 2.4)
    SimpleEntry(date: Calendar.current.date(byAdding: .hour, value: -1, to: now)!, price: 5.0)
    SimpleEntry(date: now, price: 10.0)
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
