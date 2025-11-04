//
//  TagChipsView.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI

struct TagChipsView: View {
    let tags: [String]
    var tint: Color = .accentColor

    private let columns = [GridItem(.adaptive(minimum: 70), spacing: 6)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tint.opacity(0.15), in: Capsule())
                    .foregroundStyle(tint)
            }
        }
    }
}
