//
//  HistoryCurrentView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/18/25.
//

import SwiftUI

enum GraphMode: String, CaseIterable, Identifiable {
    case overTime = "Over Time"
    case byHour = "By Hour"
    var id: String { rawValue }
}

enum ViewMode: String, CaseIterable, Identifiable {
    case list = "List"
    case graph = "Graph"
    var id: String { rawValue }
}

struct HistoryCurrentView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var userPriceManager = UserPricesManager.shared
    
    
    @State private var viewMode: ViewMode = .list
    
    
    @State private var graphMode: GraphMode = .overTime
    
    var body: some View {
        VStack {
            title
            
            pickers
            
            Group {
                switch viewMode {
                case .list:
                    HistoryListView()
                case .graph:
                    HistoryChartView(
                        graphMode: $graphMode
                    )
                }
            }
        }
        .navigationTitle("Current History")
    }
    
    private var title: some View {
        HStack {
            Text("Max Count:")
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(userPriceManager.maxPricesHistory)")
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var pickers: some View {
        Picker("View Mode", selection: $viewMode) {
            ForEach(ViewMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        
        if viewMode == .graph {
            Picker("Graph Mode", selection: $graphMode) {
                ForEach(GraphMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
    }
}

struct HistoryListView: View {
    
    @ObservedObject private var userPriceManager = UserPricesManager.shared

    var body: some View {
        List {
            ForEach(userPriceManager.prices) { price in
                HStack {
                    Text("\(price.price, specifier: "%.2f")¢")
                        .font(.largeTitle)
                    Spacer()
                    Text(price.date.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onDelete { indexSet in
                userPriceManager.deletePrices(at: indexSet)
            }
        }
        .listStyle(.plain)
    }
}
