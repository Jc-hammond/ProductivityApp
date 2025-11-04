//
//  LinkBadge.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI

struct LinkBadge: View {
    let url: URL
    @State private var isHovering = false

    private var labelText: String {
        if let host = url.host, !host.isEmpty {
            return host
        }
        return url.absoluteString
    }

    var body: some View {
        Link(destination: url) {
            Label(labelText, systemImage: "link")
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    LinearGradient(colors: [
                        Color.accentColor.opacity(isHovering ? 0.25 : 0.18),
                        Color.accentColor.opacity(isHovering ? 0.12 : 0.05)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: Capsule()
                )
                .scaleEffect(isHovering ? 1.05 : 1)
                .animation(AppAnimation.quick, value: isHovering)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.primary)
        .help(url.absoluteString)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
