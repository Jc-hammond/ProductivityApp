//
//  RecurringWeekDayColumn.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct RecurringWeekDayColumn: View {
    let dayNumber: Int // 1=Sun, 2=Mon, etc.
    let tasks: [TaskItem]
    let editTask: (TaskItem) -> Void
    let updateStatus: (TaskItem, TaskStatus) -> Void

    private var dayName: String {
        ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"][dayNumber - 1]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dayName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            VStack(spacing: 6) {
                ForEach(tasks) { task in
                    RecurringTaskCard(
                        task: task,
                        editTask: { editTask(task) },
                        updateStatus: { updateStatus(task, $0) }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
