//
//  MinimalBoardTaskCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
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
        VStack(alignment: .leading, spacing: 8) {
            // Title with repeat icon
            HStack(spacing: 4) {
                if task.recurrence != .none {
                    Image(systemName: "repeat")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                Text(task.title)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary)
            }

            // Details (if any)
            if !task.details.isEmpty {
                Text(task.details)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Subtle metadata
            if hasMetadata {
                HStack(spacing: 8) {
                    if let due = task.dueDate {
                        HStack(spacing: 3) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(due.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(.secondary)
                    }
                    if task.link != nil {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    if !task.tags.isEmpty {
                        ForEach(task.tags.prefix(2), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }

            // Action buttons (show on hover only)
            // Fixed height container to prevent layout shift
            HStack(spacing: 8) {
                if isHovering {
                    if let next = task.status.nextStep {
                        Button("→ \(next.title)") { updateStatus(next) }
                            .font(.system(size: 11))
                    }
                    Button("Edit") { editTask() }
                        .font(.system(size: 11))
                    Button("Unpin") { toggleBoard() }
                        .font(.system(size: 11))
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .frame(height: isHovering ? nil : 0)
            .clipped()
            .opacity(isHovering ? 1 : 0)
            .animation(AppAnimation.quick, value: isHovering)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHovering ? Color.primary.opacity(0.03) : Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
        .animation(AppAnimation.quick, value: isHovering)
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
