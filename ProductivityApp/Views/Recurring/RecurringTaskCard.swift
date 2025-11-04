//
//  RecurringTaskCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct RecurringTaskCard: View {
    let task: TaskItem
    let editTask: () -> Void
    let updateStatus: (TaskStatus) -> Void

    private var statusIcon: String {
        task.status == .done ? "checkmark.circle.fill" : "circle"
    }

    private var statusColor: Color {
        switch task.status {
        case .done: return .green
        case .inProgress: return .blue
        case .todo: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: statusIcon)
                    .font(.system(size: 10))
                    .foregroundStyle(statusColor)

                Text(task.status.title)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .onTapGesture {
            editTask()
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
        }
    }
}
