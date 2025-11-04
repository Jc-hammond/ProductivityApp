//
//  PreviewChip.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI

struct PreviewChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.accentColor.opacity(0.1))
                .shadow(color: Color.accentColor.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .foregroundStyle(.secondary)
        .overlay(
            Capsule()
                .strokeBorder(Color.accentColor.opacity(0.2), lineWidth: 0.5)
        )
    }
}
