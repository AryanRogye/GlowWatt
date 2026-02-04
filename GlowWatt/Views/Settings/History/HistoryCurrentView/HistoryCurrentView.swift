//
//  HistoryCurrentView.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 9/18/25.
//

import SwiftUI

struct HistoryCurrentView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var userPriceManager = UserPricesManager.shared
    
    @EnvironmentObject var uiManager : UIManager
    
    
    @SwiftUI.AppStorage("ViewMode") private var viewMode: ViewMode = .list
    @SwiftUI.AppStorage("GraphMode") private var graphMode: GraphMode = .overTime
    
    var body: some View {
        VStack {
            title
            
            pickers
            
            Group {
                switch viewMode {
                case .list:
                    HistoryListView(uiManager: uiManager)
                case .graph:
                    HistoryChartView(
                        graphMode: $graphMode
                    )
                }
            }
        }
        .navigationTitle("Current History")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Toggle("Most Recent On Top", isOn: $uiManager.mostRecentOnTop)
                } label: {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                }
            }
        }
    }
    
    private var title: some View {
        VStack {
            HStack {
                Text("Max Count:")
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(userPriceManager.maxPricesHistory)")
                    .foregroundColor(.secondary)
            }
            HStack {
                Text("Current Count: ")
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(userPriceManager.prices.count)")
                    .foregroundColor(.secondary)
            }
            Divider()
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
    @ObservedObject private var uiManager : UIManager
    
    init( uiManager: UIManager) {
        self.uiManager = uiManager
    }
    
    var prices: [PricesStorage] {
        let all = userPriceManager.prices
        if uiManager.mostRecentOnTop {
            // Sort by most recent date first
            return all.sorted { $0.date > $1.date }
        } else {
            return all
        }
    }

    var body: some View {
        List {
            ForEach(prices) { price in
                HStack {
                    Text("\(price.price, specifier: "%.2f")¢")
                        .font(.largeTitle)
                    Spacer()
                    Text(price.date.finderStyleString())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive, action: {
                        userPriceManager.deletePrice(price)
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.spring, value: prices)
    }
}

