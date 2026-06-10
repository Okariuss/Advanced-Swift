//
//  FlowLayout.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import SwiftUI

// A shared layout helper to present arrays horizontally (used for tags, categories, etc.)
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let content: (Data.Element) -> Content
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
            Spacer()
        }
    }
}
