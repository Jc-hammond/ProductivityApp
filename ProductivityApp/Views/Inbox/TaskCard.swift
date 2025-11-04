//
//  TaskCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//  Enhanced with Design System
//

import SwiftUI
import SwiftData
import AppKit

struct TaskCard: View {
    let task: TaskItem
    let updateStatus: (TaskStatus) -> Void
    let editTask: () -> Void
    let deleteTask: () -> Void
    let toggleBoard: () -> Void

    @State private var isHovering = false
    @State private var isStatusHovering = false

    private var hasMetadata: Bool {
        task.dueDate != nil || task.link != nil || !task.tags.isEmpty
    }

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
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // Status indicator - larger and more prominent
            Button(action: {
                if let nextStatus = task.status.nextStep {
                    updateStatus(nextStatus)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 10, height: 10)

                    if task.status == .done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(AppSpacing.sm)
                .scaleEffect(isStatusHovering ? 1.3 : 1.0)
                .animation(AppAnimation.springBouncy, value: isStatusHovering)
                .symbolEffect(.bounce, value: task.status)
            }
            .buttonStyle(.plain)
            .help("Change status")
            .onHover { isStatusHovering = $0 }

            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Title with repeat icon - stronger hierarchy
                HStack(spacing: AppSpacing.xs) {
                    if task.recurrence != .none {
                        Image(systemName: "repeat")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.Text.tertiary)
                    }
                    Text(task.title)
                        .font(AppTypography.body)
                        .foregroundStyle(isOverdue ? AppColors.Status.overdue : AppColors.Text.primary)
                        .fontWeight(isOverdue ? .medium : .regular)
                }

                // Details (if any)
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(AppTypography.callout)
                        .foregroundStyle(AppColors.Text.secondary)
                        .lineLimit(2)
                }

                // Refined metadata badges
                if hasMetadata {
                    HStack(spacing: AppSpacing.sm) {
                        if let due = task.dueDate {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: isOverdue ? "exclamationmark.circle.fill" : "calendar")
                                    .font(AppTypography.footnote)
                                Text(due.formatted(date: .abbreviated, time: .omitted))
                                    .font(AppTypography.caption)
                            }
                            .foregroundStyle(isOverdue ? AppColors.Status.overdue : AppColors.Text.secondary)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(
                                Capsule()
                                    .fill(isOverdue ? AppColors.Status.overdueSubtle : AppColors.Surface.tertiary)
                            )
                        }
                        if let link = task.link {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "link")
                                    .font(AppTypography.footnote)
                                Text(link.host ?? "Link")
                                    .font(AppTypography.caption)
                            }
                            .foregroundStyle(AppColors.Text.secondary)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .background(
                                Capsule()
                                    .fill(AppColors.Surface.tertiary)
                            )
                        }
                        if !task.tags.isEmpty {
                            HStack(spacing: AppSpacing.xs) {
                                ForEach(task.tags.prefix(2), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(AppTypography.footnote)
                                        .foregroundStyle(AppColors.Text.tertiary)
                                        .padding(.horizontal, AppSpacing.sm)
                                        .padding(.vertical, AppSpacing.xs)
                                        .background(
                                            Capsule()
                                                .fill(AppColors.Surface.tertiary)
                                        )
                                }
                                if task.tags.count > 2 {
                                    Text("+\(task.tags.count - 2)")
                                        .font(AppTypography.footnoteEmphasis)
                                        .foregroundStyle(AppColors.Text.tertiary)
                                }
                            }
                        }
                    }
                }

                // Action buttons (show on hover only) - more refined
                HStack(spacing: AppSpacing.sm) {
                    if isHovering {
                        Button("Edit") { editTask() }
                            .font(AppTypography.captionEmphasis)
                            .foregroundStyle(.blue)
                        Button(task.isOnBoard ? "Unpin" : "Pin") { toggleBoard() }
                            .font(AppTypography.captionEmphasis)
                            .foregroundStyle(.secondary)
                        Button("Delete") { deleteTask() }
                            .font(AppTypography.captionEmphasis)
                            .foregroundStyle(.red)
                    }
                }
                .buttonStyle(.plain)
                .frame(height: isHovering ? nil : 0)
                .clipped()
                .opacity(isHovering ? 1 : 0)
                .animation(AppAnimation.fadeIn, value: isHovering)
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.lg)
        .padding(.horizontal, AppSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .strokeBorder(cardBorder, lineWidth: 1)
        )
        .shadow(
            color: isHovering ? AppShadow.cardHover.color : AppShadow.card.color,
            radius: isHovering ? AppShadow.cardHover.radius : AppShadow.card.radius,
            x: 0,
            y: isHovering ? AppShadow.cardHover.y : AppShadow.card.y
        )
        .opacity(task.status == .done ? 0.75 : 1.0)
        .scaleEffect(isHovering && task.status != .done ? 1.005 : (task.status == .done ? 0.99 : 1.0))
        .animation(AppAnimation.springQuick, value: isHovering)
        .animation(AppAnimation.springStandard, value: task.status)
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            contextMenu
        }
    }

    private var cardBackground: Color {
        if task.status == .done {
            return AppColors.Status.doneSubtle
        } else if isHovering {
            return AppColors.Surface.cardHover
        } else {
            return AppColors.Surface.card
        }
    }

    private var cardBorder: Color {
        if isOverdue && task.status != .done {
            return AppColors.Status.overdue.opacity(0.2)
        } else if isHovering {
            return AppColors.Border.medium
        } else {
            return AppColors.Border.subtle
        }
    }
}

// MARK: - Context Menu

extension TaskCard {
    var contextMenu: some View {
        Group {
            Button(action: editTask) {
                Label("Edit Task", systemImage: "pencil")
            }

            Divider()

            Menu("Change Status") {
                ForEach(TaskStatus.allCases) { status in
                    Button(action: { updateStatus(status) }) {
                        Label(status.title, systemImage: status.iconName)
                    }
                }
            }

            Button(action: toggleBoard) {
                if task.isOnBoard {
                    Label("Unpin from Board", systemImage: "pin.slash")
                } else {
                    Label("Pin to Board", systemImage: "pin")
                }
            }

            Divider()

            Button(action: {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(task.title, forType: .string)
            }) {
                Label("Copy Task Title", systemImage: "doc.on.doc")
            }

            if let link = task.link {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(link.absoluteString, forType: .string)
                }) {
                    Label("Copy Link", systemImage: "link")
                }
            }

            Divider()

            Button(role: .destructive, action: deleteTask) {
                Label("Delete Task", systemImage: "trash")
            }
        }
    }
}
