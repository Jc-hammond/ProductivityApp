//
//  MinimalKanbanBoard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct MinimalKanbanBoard: View {
    let tasks: [TaskItem]
    let updateStatus: (TaskItem, TaskStatus) -> Void
    let editTask: (TaskItem) -> Void
    let deleteTask: (TaskItem) -> Void
    let toggleBoard: (TaskItem) -> Void

    private var groupedTasks: [TaskStatus: [TaskItem]] {
        Dictionary(grouping: tasks, by: \.status)
    }

    private var taskLookup: [UUID: TaskItem] {
        Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
    }

    private var thisWeekText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let calendar = Calendar.current
        let now = Date()

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return "This Week"
        }

        return "Week of \(formatter.string(from: weekStart))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Week indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
                Text(thisWeekText)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            if tasks.isEmpty {
                VStack(spacing: 16) {
                    Text("No tasks pinned to board")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    Text("Pin tasks from your inbox to add them here")
                        .font(.system(size: 13))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                // Three minimal columns
                HStack(alignment: .top, spacing: 24) {
                    ForEach(TaskStatus.allCases) { status in
                        MinimalKanbanColumn(
                            status: status,
                            tasks: groupedTasks[status] ?? [],
                            taskLookup: taskLookup,
                            updateStatus: updateStatus,
                            editTask: editTask,
                            deleteTask: deleteTask,
                            toggleBoard: toggleBoard
                        )
                    }
                }
            }
        }
    }
}
