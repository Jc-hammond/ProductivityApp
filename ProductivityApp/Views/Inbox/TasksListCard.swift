//
//  TasksListCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData

struct TasksListCard: View {
    let tasks: [TaskItem]
    let updateStatus: (TaskItem, TaskStatus) -> Void
    let editTask: (TaskItem) -> Void
    let deleteTask: (TaskItem) -> Void
    let toggleBoard: (TaskItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if tasks.isEmpty {
                VStack(spacing: 12) {
                    Text("No tasks")
                        .font(.system(size: 14))
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            } else {
                LazyVStack(spacing: 4) {
                    ForEach(tasks) { task in
                        TaskCard(task: task,
                                 updateStatus: { updateStatus(task, $0) },
                                 editTask: { editTask(task) },
                                 deleteTask: { deleteTask(task) },
                                 toggleBoard: { toggleBoard(task) })
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
    }
}
