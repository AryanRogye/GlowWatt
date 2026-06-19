//
//  View+modify.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 6/18/26.
//


import SwiftUI

public extension View {
    /// Applies a conditional transformation to a view via a ViewBuilder closure.
    @ViewBuilder
    func modify<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> some View {
        transform(self)
    }
}
