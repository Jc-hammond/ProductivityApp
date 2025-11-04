//
//  FiltersCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct FiltersCard: View {
    @Binding var hideDone: Bool
    @Binding var statusFilter: TaskStatus?
    let availableTags: [String]
    let activeTags: Set<String>
    let toggleTag: (String) -> Void
    let clearTags: () -> Void
    let tasks: [TaskItem]

    private var statusCounts: [TaskStatus: Int] {
        Dictionary(grouping: tasks, by: \.status).mapValues { $0.count }
    }

    private var totalTasks: Int {
        tasks.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Minimal filter buttons
            HStack(spacing: 8) {
                FilterButton(
                    title: "All",
                    count: totalTasks,
                    isSelected: statusFilter == nil,
                    action: { statusFilter = nil }
                )

                ForEach(TaskStatus.allCases) { status in
                    FilterButton(
                        title: status.title,
                        count: statusCounts[status] ?? 0,
                        isSelected: statusFilter == status,
                        action: { statusFilter = status }
                    )
                }

                if statusFilter != nil || hideDone {
                    Button(action: {
                        statusFilter = nil
                        hideDone = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(AppAnimation.quick, value: statusFilter)
            .animation(AppAnimation.quick, value: hideDone)
        }
    }
}
