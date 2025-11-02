//
//  ContentView.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI

struct TaskItem: Identifiable, Hashable {
    enum Status: String, CaseIterable, Identifiable {
        case todo
        case inProgress
        case done

        var id: String { rawValue }

        var title: String {
            switch self {
            case .todo:
                return "To Do"
            case .inProgress:
                return "In Progress"
            case .done:
                return "Done"
            }
        }

        var accentColor: Color {
            switch self {
            case .todo:
                return Color(nsColor: .systemBlue)
            case .inProgress:
                return Color(nsColor: .systemOrange)
            case .done:
                return Color(nsColor: .systemGreen)
            }
        }

        var iconName: String {
            switch self {
            case .todo:
                return "circle"
            case .inProgress:
                return "clock"
            case .done:
                return "checkmark.circle.fill"
            }
        }
    }

    let id: UUID
    var title: String
    var isOnBoard: Bool
    var status: Status

    init(id: UUID = UUID(), title: String, isOnBoard: Bool = false, status: Status = .todo) {
        self.id = id
        self.title = title
        self.isOnBoard = isOnBoard
        self.status = status
    }
}

struct ContentView: View {
    @State private var tasks: [TaskItem] = [
        TaskItem(title: "Sketch project outline", isOnBoard: true, status: .todo),
        TaskItem(title: "Design card layout", isOnBoard: true, status: .inProgress),
        TaskItem(title: "Review weekly goals", isOnBoard: false, status: .todo)
    ]
    @State private var newTaskTitle: String = ""
    @State private var selectedTaskID: TaskItem.ID?

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Task List")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Capture everything you need to get done today. Promote tasks to the board when you're ready to track progress.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    TextField("New task", text: $newTaskTitle, prompt: Text("Add something actionable"))
                        .textFieldStyle(.roundedBorder)
                        .onSubmit(addTask)
                    Button(action: addTask) {
                        Label("Add", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if tasks.isEmpty {
                    ContentUnavailableView("No tasks yet", systemImage: "square.and.pencil", description: Text("Add a task to start organizing your work."))
                        .frame(maxWidth: .infinity)
                } else {
                    List(selection: $selectedTaskID) {
                        ForEach(tasks) { task in
                            TaskListRow(task: task,
                                        toggleBoard: { toggleBoard(for: task) },
                                        updateStatus: { updateStatus(for: task, to: $0) },
                                        deleteTask: { delete(task) })
                                .tag(task.id)
                        }
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
            .background(.regularMaterial)
        } detail: {
            BoardView(tasks: tasks, updateStatus: updateStatus(for:to:))
                .padding(24)
                .background(Color(nsColor: .windowBackgroundColor))
        }
        .navigationSplitViewStyle(.balanced)
    }

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            tasks.insert(TaskItem(title: trimmed), at: 0)
            newTaskTitle = ""
        }
    }

    private func toggleBoard(for task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        withAnimation(.easeInOut) {
            tasks[index].isOnBoard.toggle()
            if tasks[index].isOnBoard == false {
                tasks[index].status = .todo
            }
        }
    }

    private func updateStatus(for task: TaskItem, to status: TaskItem.Status) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        withAnimation(.easeInOut) {
            tasks[index].status = status
            tasks[index].isOnBoard = true
        }
    }

    private func delete(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        withAnimation(.easeInOut) {
            tasks.remove(at: index)
        }
    }
}

private struct TaskListRow: View {
    let task: TaskItem
    let toggleBoard: () -> Void
    let updateStatus: (TaskItem.Status) -> Void
    let deleteTask: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(task.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
                Menu {
                    Picker("Status", selection: Binding(
                        get: { task.status },
                        set: { updateStatus($0) }
                    )) {
                        ForEach(TaskItem.Status.allCases) { status in
                            Label(status.title, systemImage: status.iconName)
                                .tag(status)
                        }
                    }
                } label: {
                    Label(task.status.title, systemImage: task.status.iconName)
                        .labelStyle(.titleAndIcon)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(task.status.accentColor.opacity(0.12))
                        .foregroundStyle(task.status.accentColor)
                        .clipShape(Capsule())
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }

            HStack(spacing: 12) {
                Button(action: toggleBoard) {
                    Label(task.isOnBoard ? "Remove from board" : "Add to board",
                          systemImage: task.isOnBoard ? "pin.slash" : "pin")
                }
                .buttonStyle(task.isOnBoard ? .borderedProminent : .borderedProminent)

                Button(role: .destructive, action: deleteTask) {
                    Label("Delete", systemImage: "trash")
                }
                .buttonStyle(.borderless)
            }
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

private struct BoardView: View {
    let tasks: [TaskItem]
    let updateStatus: (TaskItem, TaskItem.Status) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Board")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Convert tasks into cards and track them as they move from idea to done.")
                .foregroundStyle(.secondary)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(TaskItem.Status.allCases) { column in
                        BoardColumn(title: column.title,
                                    color: column.accentColor,
                                    tasks: tasks.filter { $0.isOnBoard && $0.status == column },
                                    onReassign: { updateStatus($0, column) })
                    }
                }
                .animation(.easeInOut, value: tasks)
            }
        }
    }
}

private struct BoardColumn: View {
    let title: String
    let color: Color
    let tasks: [TaskItem]
    let onReassign: (TaskItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: "rectangle.grid.1x2")
                .font(.headline)
                .foregroundStyle(color)
                .padding(.bottom, 4)

            if tasks.isEmpty {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 6]))
                    .foregroundStyle(color.opacity(0.4))
                    .overlay(
                        VStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.title3)
                                .foregroundStyle(color.opacity(0.7))
                            Text("No cards yet")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    )
                    .frame(minHeight: 160)
            } else {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        BoardCard(task: task, accent: color) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                onReassign(task)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(nsColor: .underPageBackgroundColor))
        )
    }
}

private struct BoardCard: View {
    let task: TaskItem
    let accent: Color
    let advanceAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(task.title)
                .font(.headline)
            HStack {
                Label(task.status.title, systemImage: task.status.iconName)
                    .font(.caption)
                    .foregroundStyle(accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(accent.opacity(0.12))
                    .clipShape(Capsule())
                Spacer()
                if task.status != .done {
                    Button(action: advanceAction) {
                        Label("Move forward", systemImage: "arrow.right.circle.fill")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(accent)
                } else {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(accent)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)
        )
    }
}

#Preview {
    ContentView()
        .frame(width: 1200, height: 720)
}
