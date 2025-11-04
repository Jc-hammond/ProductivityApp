//
//  TodayTasksView.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//  Enhanced with Design System
//

import SwiftUI
import SwiftData

struct TodayTasksView: View {
    let tasks: [TaskItem]
    let overdueCount: Int
    let updateStatus: (TaskItem, TaskStatus) -> Void
    let editTask: (TaskItem) -> Void
    let deleteTask: (TaskItem) -> Void
    let toggleBoard: (TaskItem) -> Void

    private var groupedTasks: (overdue: [TaskItem], today: [TaskItem]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var overdue: [TaskItem] = []
        var todayTasks: [TaskItem] = []

        for task in tasks {
            guard let dueDate = task.dueDate else { continue }
            let taskDay = calendar.startOfDay(for: dueDate)

            if taskDay < today {
                overdue.append(task)
            } else if taskDay == today {
                todayTasks.append(task)
            }
        }

        return (overdue, todayTasks)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxxl) {
            if tasks.isEmpty {
                VStack(spacing: AppSpacing.xl) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppColors.Success.fill, AppColors.Success.fill.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.pulse)

                    VStack(spacing: AppSpacing.sm) {
                        Text("You're all caught up!")
                            .font(AppTypography.title)
                            .foregroundStyle(AppColors.Text.primary)
                        Text("No tasks due today. Take a moment to breathe.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.Text.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.massive)
            } else {
                let grouped = groupedTasks

                // Overdue section - more prominent
                if !grouped.overdue.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        HStack(spacing: AppSpacing.sm) {
                            Circle()
                                .fill(AppColors.Status.overdue)
                                .frame(width: 10, height: 10)
                            Text("Overdue")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.Status.overdue)
                            Text("\(grouped.overdue.count)")
                                .font(AppTypography.callout)
                                .foregroundStyle(AppColors.Text.tertiary)
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, AppSpacing.xs)
                                .background(
                                    Capsule()
                                        .fill(AppColors.Status.overdueSubtle)
                                )
                        }

                        LazyVStack(spacing: AppSpacing.xs) {
                            ForEach(grouped.overdue) { task in
                                TaskCard(task: task,
                                        updateStatus: { updateStatus(task, $0) },
                                        editTask: { editTask(task) },
                                        deleteTask: { deleteTask(task) },
                                        toggleBoard: { toggleBoard(task) })
                            }
                        }
                    }
                }

                // Today section - refined
                if !grouped.today.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        HStack(spacing: AppSpacing.sm) {
                            Circle()
                                .fill(AppColors.Warning.fill)
                                .frame(width: 10, height: 10)
                            Text("Today")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.Warning.fill)
                            Text("\(grouped.today.count)")
                                .font(AppTypography.callout)
                                .foregroundStyle(AppColors.Text.tertiary)
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, AppSpacing.xs)
                                .background(
                                    Capsule()
                                        .fill(AppColors.Warning.background)
                                )
                        }

                        LazyVStack(spacing: AppSpacing.xs) {
                            ForEach(grouped.today) { task in
                                TaskCard(task: task,
                                        updateStatus: { updateStatus(task, $0) },
                                        editTask: { editTask(task) },
                                        deleteTask: { deleteTask(task) },
                                        toggleBoard: { toggleBoard(task) })
                            }
                        }
                    }
                }
            }
        }
    }
}
