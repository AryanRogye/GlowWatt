//
//  ToolbarCancel.swift
//  GlowWatt
//
//  Created by Aryan Rogye on 10/28/25.
//

import SwiftUI

struct ToolbarCancel: ViewModifier {
    
    @Binding var cancel : Bool
    
    init(_ cancel: Binding<Bool>) {
        _cancel = cancel
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        cancel = false
                    }) {
                        Text("Cancel")
                            .font(.headline)
                    }
                    .labelStyle(.titleOnly)
                }
            }
    }
}

extension View {
    func toolbarCancel(_ cancel: Binding<Bool>) -> some View {
        self.modifier(ToolbarCancel(cancel))
    }
}
