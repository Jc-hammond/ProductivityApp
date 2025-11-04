//
//  RecurringTasksWeekView.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct RecurringTasksWeekView: View {
    let tasks: [TaskItem]
    let editTask: (TaskItem) -> Void
    let updateStatus: (TaskItem, TaskStatus) -> Void

    private func tasks(for dayOfWeek: Int) -> [TaskItem] {
        tasks.filter { $0.dayOfWeek == dayOfWeek }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recurring Tasks")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 12) {
                ForEach(1...7, id: \.self) { day in
                    RecurringWeekDayColumn(
                        dayNumber: day,
                        tasks: tasks(for: day),
                        editTask: editTask,
                        updateStatus: updateStatus
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
    }
}
