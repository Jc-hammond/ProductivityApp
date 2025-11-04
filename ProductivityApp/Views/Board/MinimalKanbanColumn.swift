//
//  MinimalKanbanColumn.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//  Enhanced with Design System
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
        case .todo: return AppColors.Status.todo
        case .inProgress: return AppColors.Status.inProgress
        case .done: return AppColors.Status.done
        }
    }

    private var columnBackground: Color {
        switch status {
        case .todo: return AppColors.Status.todoSubtle.opacity(0.3)
        case .inProgress: return AppColors.Status.inProgressSubtle.opacity(0.3)
        case .done: return AppColors.Status.doneSubtle.opacity(0.3)
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
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            // Column header - more prominent
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)
                    Text(status.title)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.Text.primary)
                    Spacer()
                    Text("\(tasks.count)")
                        .font(AppTypography.captionEmphasis)
                        .foregroundStyle(AppColors.Text.tertiary)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
                            Capsule()
                                .fill(AppColors.Surface.tertiary)
                        )
                }

                Divider()
                    .background(statusColor.opacity(0.2))
            }

            // Tasks in column
            if tasks.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.Text.tertiary)
                    Text("No tasks")
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.Text.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xxxl)
            } else {
                VStack(spacing: AppSpacing.sm) {
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
                .animation(AppAnimation.springStandard, value: sortedTasks.map { $0.id })
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .fill(isTargeted ? statusColor.opacity(0.12) : columnBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .strokeBorder(
                    isTargeted ? statusColor.opacity(0.4) : statusColor.opacity(0.15),
                    lineWidth: isTargeted ? 2 : 1
                )
        )
        .shadow(
            color: isTargeted ? statusColor.opacity(0.2) : AppShadow.card.color,
            radius: isTargeted ? 12 : AppShadow.card.radius,
            x: 0,
            y: isTargeted ? 6 : AppShadow.card.y
        )
        .animation(AppAnimation.springQuick, value: isTargeted)
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
