//
//  BoardColumnView.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct BoardColumnView: View {
    let status: TaskStatus
    let tasks: [TaskItem]
    let updateStatus: (TaskItem, TaskStatus) -> Void
    let toggleBoard: (TaskItem) -> Void
    let taskLookup: [UUID: TaskItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(status.title, systemImage: status.iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(status.accentColor)

            if tasks.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: status == .done ? "checkmark.circle" : "tray")
                        .font(.system(size: 28))
                        .foregroundStyle(.tertiary)
                        .symbolEffect(.pulse, value: tasks.isEmpty)
                    Text(status == .todo ? "Pin tasks to start" : status == .inProgress ? "Nothing in progress" : "All done!")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .transition(.scale.combined(with: .opacity))
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
            } else {
                VStack(spacing: 14) {
                    ForEach(tasks) { task in
                        BoardCard(task: task,
                                  accent: status.accentColor,
                                  advanceStatus: {
                                      if let next = task.status.nextStep {
                                          updateStatus(task, next)
                                      }
                                  },
                                  toggleBoard: { toggleBoard(task) })
                            .onDrag {
                                NSItemProvider(object: task.id.uuidString as NSString)
                            }
                    }
                }
            }
        }
        .dropDestination(for: String.self) { items, _ in
            guard let idString = items.first,
                  let uuid = UUID(uuidString: idString),
                  let task = taskLookup[uuid] else { return false }
            updateStatus(task, status)
            return true
        } isTargeted: { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                targetHovering = hovering
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(status.accentColor.opacity(targetHovering ? 0.08 : 0.0))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(status.accentColor.opacity(targetHovering ? 0.8 : 0.0), lineWidth: 3)
        )
        .shadow(color: status.accentColor.opacity(targetHovering ? 0.3 : 0.0), radius: targetHovering ? 20 : 0, x: 0, y: 0)
    }

    @State private var targetHovering: Bool = false
}
