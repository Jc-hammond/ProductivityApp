//
//  TodayView.swift
//  ProductivityApp (iOS - iPhone)
//
//  Today's tasks view optimized for iPhone
//

import SwiftUI
import SwiftData

struct iPhone_TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]

    private var todayTasks: [TaskItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDay = calendar.startOfDay(for: dueDate)
            return taskDay <= today && task.status != .done
        }.sorted { lhs, rhs in
            guard let lhsDate = lhs.dueDate, let rhsDate = rhs.dueDate else { return false }
            return lhsDate < rhsDate
        }
    }

    private var groupedTasks: (overdue: [TaskItem], today: [TaskItem]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var overdue: [TaskItem] = []
        var todayList: [TaskItem] = []

        for task in todayTasks {
            guard let dueDate = task.dueDate else { continue }
            let taskDay = calendar.startOfDay(for: dueDate)

            if taskDay < today {
                overdue.append(task)
            } else {
                todayList.append(task)
            }
        }

        return (overdue, todayList)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    if todayTasks.isEmpty {
                        emptyState
                    } else {
                        let grouped = groupedTasks

                        if !grouped.overdue.isEmpty {
                            overdueSection(tasks: grouped.overdue)
                        }

                        if !grouped.today.isEmpty {
                            todaySection(tasks: grouped.today)
                        }
                    }
                }
                .padding(AppSpacing.lg)
                .padding(.bottom, 80) // Space for FAB
            }
            .background(AppColors.Surface.primary)
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.Success.fill, AppColors.Success.fill.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse)

            VStack(spacing: AppSpacing.sm) {
                Text("All done for today!")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.Text.primary)

                Text("Take a moment to breathe.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.Text.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.massive)
    }

    private func overdueSection(tasks: [TaskItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(AppColors.Status.overdue)
                    .frame(width: 10, height: 10)
                Text("Overdue")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.Status.overdue)

                Spacer()

                Text("\(tasks.count)")
                    .font(AppTypography.captionEmphasis)
                    .foregroundStyle(AppColors.Text.tertiary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        Capsule()
                            .fill(AppColors.Status.overdueSubtle)
                    )
            }

            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(tasks) { task in
                    iPhone_TaskRow(task: task)
                }
            }
        }
    }

    private func todaySection(tasks: [TaskItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(AppColors.Warning.fill)
                    .frame(width: 10, height: 10)
                Text("Today")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.Warning.fill)

                Spacer()

                Text("\(tasks.count)")
                    .font(AppTypography.captionEmphasis)
                    .foregroundStyle(AppColors.Text.tertiary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        Capsule()
                            .fill(AppColors.Warning.background)
                    )
            }

            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(tasks) { task in
                    iPhone_TaskRow(task: task)
                }
            }
        }
    }
}
