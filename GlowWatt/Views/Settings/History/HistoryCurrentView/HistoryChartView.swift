//
//  HistoryChartView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/18/25.
//

import SwiftUI
import Charts

struct HistoryChartView: View {
    @Binding var graphMode: GraphMode
    @ObservedObject private var userPriceManager = UserPricesManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            switch graphMode {
            case .overTime:
                overTimeChart
                helperText("This shows how the price changes over days. Higher means more expensive.")
            case .byHour:
                byHourChart
                helperText("This shows the average price at each hour of the day.")
            }
        }
        .padding()
    }
}

// MARK: - Sections
private extension HistoryChartView {
    @ViewBuilder
    var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2).bold()
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
    
    var overTimeChart: some View {
        let sorted = userPriceManager.prices.sorted { $0.date < $1.date }
        let maxPrice = (sorted.map { $0.price }.max() ?? 0)
        
        return Chart(sorted) { price in
            AreaMark(
                x: .value("Date", price.date),
                y: .value("Price (¢)", price.price)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(Gradient(colors: [.blue.opacity(0.35), .blue.opacity(0.15)]))
            
            LineMark(
                x: .value("Date", price.date),
                y: .value("Price (¢)", price.price)
            )
            .interpolationMethod(.monotone)
            .foregroundStyle(.blue)
            .lineStyle(StrokeStyle(lineWidth: 3))
        }
        .chartYScale(domain: 0...(maxPrice * 1.2 + 0.01))
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxisLabel("Date")
        .chartYAxisLabel("Price (¢)")
        .frame(minHeight: 320)
        .accessibilityLabel("Prices over time")
    }
    
    var byHourChart: some View {
        // Average price per hour of day (0-23)
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: userPriceManager.prices) { price in
            calendar.component(.hour, from: price.date)
        }
        let hourAverages: [(hour: Int, avg: Double)] = grouped.map { (hour, items) in
            let sum = items.reduce(0.0) { $0 + $1.price }
            let avg = items.isEmpty ? 0.0 : (sum / Double(items.count))
            return (hour: hour, avg: avg)
        }
        .sorted { $0.hour < $1.hour }
        
        return Chart(hourAverages, id: \.hour) { bucket in
            BarMark(
                x: .value("Hour", hourLabel(bucket.hour)),
                y: .value("Avg Price (¢)", bucket.avg)
            )
            .foregroundStyle(.blue.gradient)
            .annotation(position: .top, alignment: .center) {
                Text("\(bucket.avg, specifier: "%.0f")¢")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .chartXAxis {
            AxisMarks(values: Array(stride(from: 0, through: 23, by: 3)).map { hourLabel($0) }) { value in
                AxisGridLine()
                AxisTick()
                if let label = value.as(String.self) {
                    AxisValueLabel(label)
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxisLabel("Hour of Day")
        .chartYAxisLabel("Avg Price (¢)")
        .frame(minHeight: 320)
        .accessibilityLabel("Average price by hour of day")
    }
    
    func helperText(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(.secondary)
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Helpers
private extension HistoryChartView {
    var title: String {
        switch graphMode {
        case .overTime: return "Prices Over Time"
        case .byHour:   return "Average Price by Hour"
        }
    }
    
    var subtitle: String {
        switch graphMode {
        case .overTime: return "A simple line showing price changes."
        case .byHour:   return "Bars show which hours are usually cheaper or expensive."
        }
    }
    
    func hourLabel(_ hour: Int) -> String {
        let h = hour % 24
        if h == 0 { return "12a" }
        if h == 12 { return "12p" }
        return h < 12 ? "\(h)a" : "\(h - 12)p"
    }
}

