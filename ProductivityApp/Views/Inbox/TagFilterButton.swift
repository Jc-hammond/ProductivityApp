//
//  TagFilterButton.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI

struct TagFilterButton: View {
    let tag: String
    let isActive: Bool
    let toggle: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: toggle) {
            Text(tag)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    isActive ? Color.accentColor.opacity(isHovering ? 0.25 : 0.18) : Color.primary.opacity(isHovering ? 0.1 : 0.06)
                )
                .foregroundStyle(isActive ? Color.accentColor : .primary)
                .clipShape(Capsule())
                .scaleEffect(isHovering ? 1.05 : 1)
                .animation(AppAnimation.quick, value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
