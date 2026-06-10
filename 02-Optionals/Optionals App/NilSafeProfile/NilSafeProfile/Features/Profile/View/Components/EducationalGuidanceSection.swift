//
//  EducationalGuidanceSection.swift
//  NilSafeProfile
//
//  Created by Okan Orkun on 9.06.2026.
//

import SwiftUI

struct EducationalGuidanceSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Developer Education Notes")
                .font(.caption)
                .bold()
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Group {
                Text("⚠️ Force Unwrapping (!)")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.red)
                
                Text("Never use 'user.email!' in production code. If the value is nil, your app will crash instantly. Only use it in unit tests or when you can prove the value is 100% not nil.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Divider().background(.white.opacity(0.2))
            
            Group {
                Text("⚙️ Implicitly Unwrapped Optionals (IUO)")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.orange)
                
                Text("IUOs (like 'var label: UILabel!') mainly exist for UIKit @IBOutlets and Objective-C compatibility. Avoid using them when designing pure Swift APIs.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .glassCardStyle()
    }
}
