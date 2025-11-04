//
//  BoardView.swift
//  ProductivityApp (iOS - iPhone)
//
//  Simplified board view for iPhone - vertical scroll through statuses
//

import SwiftUI
import SwiftData

struct iPhone_BoardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]

    private var boardTasks: [TaskItem] {
        tasks.filter { $0.isOnBoard }
    }

    private var groupedTasks: [TaskStatus: [TaskItem]] {
        Dictionary(grouping: boardTasks, by: \.status)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                    if boardTasks.isEmpty {
                        emptyState
                    } else {
                        ForEach(TaskStatus.allCases) { status in
                            statusSection(status: status, tasks: groupedTasks[status] ?? [])
                        }
                    }
                }
                .padding(AppSpacing.lg)
                .padding(.bottom, 80) // Space for FAB
            }
            .background(AppColors.Surface.primary)
            .navigationTitle("Board")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "rectangle.3.group")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.Text.tertiary)

            VStack(spacing: AppSpacing.sm) {
                Text("No tasks on board")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.Text.secondary)

                Text("Pin tasks from Inbox to organize them here")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.Text.tertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.massive)
    }

    private func statusSection(status: TaskStatus, tasks: [TaskItem]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            HStack(spacing: AppSpacing.sm) {
                Circle()
                    .fill(status.accentColor)
                    .frame(width: 12, height: 12)

                Text(status.title)
                    .font(AppTypography.headline)
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

            if tasks.isEmpty {
                Text("No tasks")
                    .font(AppTypography.callout)
                    .foregroundStyle(AppColors.Text.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppSpacing.xl)
            } else {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(tasks) { task in
                        iPhone_TaskRow(task: task)
                    }
                }
            }

            Divider()
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .fill(status.accentColor.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .strokeBorder(status.accentColor.opacity(0.15), lineWidth: 1)
        )
    }
}
