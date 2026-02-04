//
//  Graph.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/6/25.
//

import Foundation

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
