//
//  KanbanBoard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct KanbanBoard: View {
    let tasks: [TaskItem]
    let updateStatus: (TaskItem, TaskStatus) -> Void
    let toggleBoard: (TaskItem) -> Void

    private var groupedTasks: [TaskStatus: [TaskItem]] {
        Dictionary(grouping: tasks, by: \.status)
    }
    private var lookup: [UUID: TaskItem] {
        Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Board")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 16)], alignment: .leading, spacing: 16) {
                ForEach(TaskStatus.allCases) { status in
                    BoardColumnView(status: status,
                                    tasks: groupedTasks[status] ?? [],
                                    updateStatus: updateStatus,
                                    toggleBoard: toggleBoard,
                                    taskLookup: lookup)
                }
            }
        }
    }
}
