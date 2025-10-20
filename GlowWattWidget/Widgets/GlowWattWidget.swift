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
        // 1) read what the intent (or app) stored
        let storedPrice : Double = AppStorage.getPrice() ?? .nan
        let lastUpdated : Date = AppStorage.getLastUpdated() ?? .distantPast
        let isStale : Bool = Date().timeIntervalSince(lastUpdated) > 25 * 60  // ~25 min
        
        // 2) fetch only if missing/stale
        let price: Double
        if storedPrice.isNaN || isStale {
            let fetched : Double = await API.fetchComEdPrice() ?? (storedPrice.isNaN ? 0.0 : storedPrice)
            AppStorage.setPrice(fetched)
            AppStorage.setLastUpdated()
            price = fetched
        } else {
            price = storedPrice
        }
        
        let entry = SimpleEntry(date: .now, price: price)
        return Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(1800)))
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
            .minimumScaleFactor(0.5)
            .lineLimit(1)
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
        case .accessoryRectangular:
            return 24
        case .systemSmall:
            return 36
        case .systemMedium:
            return 36
        case .systemLarge:
            return 100
        case .systemExtraLarge:
            return 100
        default:
            return 20
        }
    }
    
    // MARK: - Accented Status
    @ViewBuilder
    private var accentedStatus: some View {
        switch priceColor {
        case .green:
            Image(systemName: "checkmark.circle.fill")
        case .yellow:
            Image(systemName: "exclamationmark.circle.fill")
        case .red:
            Image(systemName: "xmark.octagon.fill")
        default:
            Image(systemName: "questionmark.circle.fill")
        }
    }
    
    // MARK: - Accented Status View
    private func accentedStatusView(
        scale: CGFloat
    ) -> some View {
        accentedStatus
            .font(.system(size: fontSize * scale, weight: .semibold))
            .foregroundColor(.white)
    }

    // MARK: - Date Display
    private func dateDisplay(
        scale: CGFloat,
        updatedOpacity: Double = 0.75,
        timestampOpacity: Double = 0.6
    ) -> some View {
        HStack {
            Text(relativeTimestamp)
                .font(.system(size: fontSize * scale, weight: .bold))
                .foregroundColor(.white.opacity(timestampOpacity))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            if widgetRenderingMode == .accented {
                accentedStatusView(scale: 0.4)
                    .minimumScaleFactor(0.5)
            }
            Spacer()
            Button(intent: FetchCurrentInstantHourlyPrice()) {
                Circle()
                    .fill(.clear)
                    .strokeBorder(.white, style: StrokeStyle(lineWidth: 2))
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: "arrow.clockwise")
                            .frame(alignment: .center)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
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
                Spacer()
                
                PriceFormatted(entry: entry, fontSize: fontSize)
                
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .widgetURL(URL(string: "glowwatt://refresh"))
            .animation(.spring, value: entry.price)
            .animation(.spring, value: widgetRenderingMode)
        }
    }
    
    // MARK: - Acessory Rectangle
    @ViewBuilder
    private var accessoryRectangularView: some View {
        Text(relativeTimestamp)
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
        }
    }
}

struct GlowWattWidgetHomeScreen: Widget {
    let kind: String = "GlowWattWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
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
