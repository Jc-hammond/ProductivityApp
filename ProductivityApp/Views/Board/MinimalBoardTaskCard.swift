//
//  MinimalBoardTaskCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//  Enhanced with Design System
//

import SwiftUI
import SwiftData

struct MinimalBoardTaskCard: View {
    let task: TaskItem
    let statusColor: Color
    let updateStatus: (TaskStatus) -> Void
    let editTask: () -> Void
    let deleteTask: () -> Void
    let toggleBoard: () -> Void

    @State private var isHovering = false

    private var hasMetadata: Bool {
        task.dueDate != nil || task.link != nil || !task.tags.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Title with repeat icon - enhanced
            HStack(spacing: AppSpacing.xs) {
                if task.recurrence != .none {
                    Image(systemName: "repeat")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.Text.tertiary)
                }
                Text(task.title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.Text.primary)
            }

            // Details (if any)
            if !task.details.isEmpty {
                Text(task.details)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.Text.secondary)
                    .lineLimit(2)
            }

            // Refined metadata badges
            if hasMetadata {
                HStack(spacing: AppSpacing.xs) {
                    if let due = task.dueDate {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "calendar")
                                .font(AppTypography.footnote)
                            Text(due.formatted(date: .abbreviated, time: .omitted))
                                .font(AppTypography.footnote)
                        }
                        .foregroundStyle(AppColors.Text.secondary)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(AppColors.Surface.tertiary)
                        )
                    }
                    if task.link != nil {
                        Image(systemName: "link")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.Text.secondary)
                            .padding(AppSpacing.xs)
                            .background(
                                Circle()
                                    .fill(AppColors.Surface.tertiary)
                            )
                    }
                    if !task.tags.isEmpty {
                        ForEach(task.tags.prefix(1), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(AppTypography.footnoteEmphasis)
                                .foregroundStyle(AppColors.Text.tertiary)
                        }
                        if task.tags.count > 1 {
                            Text("+\(task.tags.count - 1)")
                                .font(AppTypography.footnoteEmphasis)
                                .foregroundStyle(AppColors.Text.tertiary)
                        }
                    }
                }
            }

            // Action buttons (show on hover only) - refined
            HStack(spacing: AppSpacing.xs) {
                if isHovering {
                    if let next = task.status.nextStep {
                        Button("→ \(next.title)") { updateStatus(next) }
                            .font(AppTypography.footnoteEmphasis)
                    }
                    Button("Edit") { editTask() }
                        .font(AppTypography.footnoteEmphasis)
                    Button("Unpin") { toggleBoard() }
                        .font(AppTypography.footnoteEmphasis)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .frame(height: isHovering ? nil : 0)
            .clipped()
            .opacity(isHovering ? 1 : 0)
            .animation(AppAnimation.fadeIn, value: isHovering)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .fill(isHovering ? AppColors.Surface.cardHover : AppColors.Surface.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .strokeBorder(isHovering ? AppColors.Border.medium : AppColors.Border.subtle, lineWidth: 1)
        )
        .shadow(
            color: isHovering ? AppShadow.cardHover.color.opacity(0.5) : Color.clear,
            radius: isHovering ? 8 : 0,
            x: 0,
            y: isHovering ? 4 : 0
        )
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .animation(AppAnimation.springQuick, value: isHovering)
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button(action: editTask) {
                Label("Edit Task", systemImage: "pencil")
            }

            if let next = task.status.nextStep {
                Button(action: { updateStatus(next) }) {
                    Label("Move to \(next.title)", systemImage: "arrow.right")
                }
            }

            Button(action: toggleBoard) {
                Label("Unpin from Board", systemImage: "pin.slash")
            }

            Divider()

            Button(role: .destructive, action: deleteTask) {
                Label("Delete Task", systemImage: "trash")
            }
        }
    }
}
