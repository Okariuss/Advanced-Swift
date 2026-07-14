//
//  CustomLabeledContent.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import SwiftUI

struct CustomLabeledContent: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).bold().foregroundColor(.primary)
        }
    }
}
