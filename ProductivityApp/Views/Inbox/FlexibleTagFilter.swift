//
//  FlexibleTagFilter.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI

struct FlexibleTagFilter: View {
    let tags: [String]
    let activeTags: Set<String>
    let toggle: (String) -> Void

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 80), spacing: 8)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                TagFilterButton(tag: tag, isActive: activeTags.contains(tag), toggle: { toggle(tag) })
            }
        }
    }
}
