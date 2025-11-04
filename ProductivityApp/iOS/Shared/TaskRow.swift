//
//  TaskRow.swift
//  ProductivityApp (iOS)
//
//  Swipeable task row for iPhone/iPad lists
//

import SwiftUI
import SwiftData

struct iPhone_TaskRow: View {
    let task: TaskItem
    @Environment(\.modelContext) private var modelContext

    @State private var isShowingDetail = false

    private var statusColor: Color {
        switch task.status {
        case .todo: return AppColors.Status.todo
        case .inProgress: return AppColors.Status.inProgress
        case .done: return AppColors.Status.done
        }
    }

    private var isOverdue: Bool {
        guard let due = task.dueDate else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let taskDay = calendar.startOfDay(for: due)
        return taskDay < today && task.status != .done
    }

    var body: some View {
        Button(action: { isShowingDetail = true }) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                // Status indicator
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    // Title
                    Text(task.title)
                        .font(AppTypography.body)
                        .foregroundStyle(isOverdue ? AppColors.Status.overdue : AppColors.Text.primary)
                        .fontWeight(isOverdue ? .medium : .regular)
                        .multilineTextAlignment(.leading)

                    // Metadata
                    if task.dueDate != nil || !task.tags.isEmpty {
                        HStack(spacing: AppSpacing.sm) {
                            if let due = task.dueDate {
                                HStack(spacing: AppSpacing.xs) {
                                    Image(systemName: isOverdue ? "exclamationmark.circle.fill" : "calendar")
                                        .font(AppTypography.footnote)
                                    Text(due.formatted(date: .abbreviated, time: .omitted))
                                        .font(AppTypography.caption)
                                }
                                .foregroundStyle(isOverdue ? AppColors.Status.overdue : AppColors.Text.secondary)
                            }

                            if !task.tags.isEmpty {
                                Text("#\(task.tags.first!)")
                                    .font(AppTypography.footnoteEmphasis)
                                    .foregroundStyle(AppColors.Text.tertiary)

                                if task.tags.count > 1 {
                                    Text("+\(task.tags.count - 1)")
                                        .font(AppTypography.footnote)
                                        .foregroundStyle(AppColors.Text.tertiary)
                                }
                            }
                        }
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.Text.tertiary)
            }
            .padding(AppSpacing.lg)
            .frame(minHeight: AppTouchTarget.comfortable)
            .background(AppColors.Surface.card)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .strokeBorder(
                        isOverdue ? AppColors.Status.overdue.opacity(0.2) : AppColors.Border.subtle,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteTask()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                completeTask()
            } label: {
                Label("Complete", systemImage: "checkmark.circle.fill")
            }
            .tint(AppColors.Success.fill)
        }
        .sheet(isPresented: $isShowingDetail) {
            NavigationStack {
                Text("Task detail coming soon")
                    .navigationTitle("Task Details")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isShowingDetail = false
                            }
                        }
                    }
            }
        }
    }

    private func completeTask() {
        withAnimation(AppAnimation.springStandard) {
            task.status = .done
        }

        #if os(iOS)
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    private func deleteTask() {
        withAnimation(AppAnimation.standard) {
            modelContext.delete(task)
        }

        #if os(iOS)
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }
}
