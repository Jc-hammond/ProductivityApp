//
//  TaskCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
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
        case .todo: return Color.gray
        case .inProgress: return Color.blue
        case .done: return Color.green
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Subtle status indicator (dot) with completion animation
            Button(action: {
                if let nextStatus = task.status.nextStep {
                    updateStatus(nextStatus)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)

                    if task.status == .done {
                        Image(systemName: "checkmark")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(.white)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(6)
                .scaleEffect(isStatusHovering ? 1.2 : 1.0)
                .animation(AppAnimation.quick, value: isStatusHovering)
                .symbolEffect(.bounce, value: task.status)
            }
            .buttonStyle(.plain)
            .help("Change status")
            .onHover { isStatusHovering = $0 }

            VStack(alignment: .leading, spacing: 8) {
                // Title with repeat icon
                HStack(spacing: 4) {
                    if task.recurrence != .none {
                        Image(systemName: "repeat")
                            .font(.system(size: 11))
                            .foregroundStyle(.tertiary)
                    }
                    Text(task.title)
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                }

                // Details (if any)
                if !task.details.isEmpty {
                    Text(task.details)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Subtle metadata
                if hasMetadata {
                    HStack(spacing: 10) {
                        if let due = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 11))
                                Text(due.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(.secondary)
                        }
                        if let link = task.link {
                            HStack(spacing: 4) {
                                Image(systemName: "link")
                                    .font(.system(size: 11))
                                Text(link.host ?? "Link")
                                    .font(.system(size: 12))
                            }
                            .foregroundStyle(.secondary)
                        }
                        if !task.tags.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(task.tags.prefix(3), id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }

                // Action buttons (show on hover only)
                // Fixed height container to prevent layout shift
                HStack(spacing: 8) {
                    if isHovering {
                        Button("Edit") { editTask() }
                            .font(.system(size: 12))
                        Button(task.isOnBoard ? "Unpin" : "Pin") { toggleBoard() }
                            .font(.system(size: 12))
                        Button("Delete") { deleteTask() }
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                    }
                }
                .buttonStyle(.plain)
                .frame(height: isHovering ? nil : 0)
                .clipped()
                .opacity(isHovering ? 1 : 0)
                .animation(AppAnimation.quick, value: isHovering)
            }

            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(task.status == .done ? Color.green.opacity(0.05) : (isHovering ? Color.primary.opacity(0.03) : Color.clear))
        )
        .opacity(task.status == .done ? 0.7 : 1.0)
        .scaleEffect(task.status == .done ? 0.98 : 1.0)
        .animation(AppAnimation.quick, value: isHovering)
        .animation(AppAnimation.springStandard, value: task.status)
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
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
