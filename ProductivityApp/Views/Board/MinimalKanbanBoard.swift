//
//  MinimalKanbanBoard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//  Enhanced with Design System
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
        VStack(alignment: .leading, spacing: AppSpacing.xxl) {
            // Week indicator - more prominent
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(AppColors.Status.inProgress)
                    .frame(width: 8, height: 8)
                Text(thisWeekText)
                    .font(AppTypography.calloutEmphasis)
                    .foregroundStyle(AppColors.Text.secondary)
            }

            if tasks.isEmpty {
                VStack(spacing: AppSpacing.lg) {
                    Image(systemName: "rectangle.3.group")
                        .font(.system(size: 48))
                        .foregroundStyle(AppColors.Text.tertiary)
                        .symbolEffect(.pulse)

                    VStack(spacing: AppSpacing.sm) {
                        Text("No tasks pinned to board")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.Text.secondary)
                        Text("Pin tasks from your inbox to organize them here")
                            .font(AppTypography.callout)
                            .foregroundStyle(AppColors.Text.tertiary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.massive)
            } else {
                // Three columns with better spacing
                HStack(alignment: .top, spacing: AppSpacing.lg) {
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
