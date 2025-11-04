//
//  ShortcutRow.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI

struct ShortcutRow: View {
    let key: String
    let description: String

    var body: some View {
        HStack {
            Text(key)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
            Text(description)
                .font(.callout)
            Spacer()
        }
    }
}
