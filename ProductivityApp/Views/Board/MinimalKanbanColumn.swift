//
//  MinimalKanbanColumn.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct MinimalKanbanColumn: View {
    let status: TaskStatus
    let tasks: [TaskItem]
    let taskLookup: [UUID: TaskItem]
    let updateStatus: (TaskItem, TaskStatus) -> Void
    let editTask: (TaskItem) -> Void
    let deleteTask: (TaskItem) -> Void
    let toggleBoard: (TaskItem) -> Void

    @State private var isTargeted = false

    private var statusColor: Color {
        switch status {
        case .todo: return .gray
        case .inProgress: return .blue
        case .done: return .green
        }
    }

    private var sortedTasks: [TaskItem] {
        tasks.sorted { lhs, rhs in
            // Recurring tasks always appear first
            if lhs.recurrence != .none && rhs.recurrence == .none {
                return true
            } else if lhs.recurrence == .none && rhs.recurrence != .none {
                return false
            }
            // Within same recurrence type, sort by title
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Column header with dot
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
                Text(status.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("\(tasks.count)")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 4)

            // Tasks in column
            if tasks.isEmpty {
                Text("No tasks")
                    .font(.system(size: 13))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 4) {
                    ForEach(sortedTasks) { task in
                        MinimalBoardTaskCard(
                            task: task,
                            statusColor: statusColor,
                            updateStatus: { updateStatus(task, $0) },
                            editTask: { editTask(task) },
                            deleteTask: { deleteTask(task) },
                            toggleBoard: { toggleBoard(task) }
                        )
                        .onDrag {
                            NSItemProvider(object: task.id.uuidString as NSString)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(AppAnimation.standard, value: sortedTasks.map { $0.id })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isTargeted ? statusColor.opacity(0.08) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(isTargeted ? statusColor.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .animation(AppAnimation.standard, value: isTargeted)
        .dropDestination(for: String.self) { items, _ in
            guard let idString = items.first,
                  let uuid = UUID(uuidString: idString),
                  let task = taskLookup[uuid] else { return false }

            updateStatus(task, status)
            return true
        } isTargeted: { targeted in
            isTargeted = targeted
        }
    }
}
