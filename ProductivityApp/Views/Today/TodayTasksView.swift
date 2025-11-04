//
//  TodayTasksView.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct TodayTasksView: View {
    let tasks: [TaskItem]
    let overdueCount: Int
    let updateStatus: (TaskItem, TaskStatus) -> Void
    let editTask: (TaskItem) -> Void
    let deleteTask: (TaskItem) -> Void
    let toggleBoard: (TaskItem) -> Void

    private var groupedTasks: (overdue: [TaskItem], today: [TaskItem]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var overdue: [TaskItem] = []
        var todayTasks: [TaskItem] = []

        for task in tasks {
            guard let dueDate = task.dueDate else { continue }
            let taskDay = calendar.startOfDay(for: dueDate)

            if taskDay < today {
                overdue.append(task)
            } else if taskDay == today {
                todayTasks.append(task)
            }
        }

        return (overdue, todayTasks)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            if tasks.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                        .symbolEffect(.pulse)
                    Text("You're all caught up!")
                        .font(.system(size: 20, weight: .semibold))
                    Text("No tasks due today")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 64)
            } else {
                let grouped = groupedTasks

                // Overdue section
                if !grouped.overdue.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("Overdue")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.red)
                            Text("\(grouped.overdue.count)")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }

                        LazyVStack(spacing: 4) {
                            ForEach(grouped.overdue) { task in
                                TaskCard(task: task,
                                        updateStatus: { updateStatus(task, $0) },
                                        editTask: { editTask(task) },
                                        deleteTask: { deleteTask(task) },
                                        toggleBoard: { toggleBoard(task) })
                            }
                        }
                    }
                }

                // Today section
                if !grouped.today.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                            Text("Today")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.orange)
                            Text("\(grouped.today.count)")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }

                        LazyVStack(spacing: 4) {
                            ForEach(grouped.today) { task in
                                TaskCard(task: task,
                                        updateStatus: { updateStatus(task, $0) },
                                        editTask: { editTask(task) },
                                        deleteTask: { deleteTask(task) },
                                        toggleBoard: { toggleBoard(task) })
                            }
                        }
                    }
                }
            }
        }
    }
}
