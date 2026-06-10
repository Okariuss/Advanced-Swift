//
//  GlassCardModifier.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import SwiftUI

// A shared visual design theme used across the entire application
struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .glassEffect(.clear, in: .rect(cornerRadius: 12))
    }
}

extension View {
    func glassCardStyle() -> some View {
        self.modifier(GlassCardModifier())
    }
}

