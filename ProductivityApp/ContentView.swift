//
//  ContentView.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI
import Foundation
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.undoManager) private var undoManager
    @Query private var tasks: [TaskItem]

    @State private var selectedView: ViewType = .today
    @State private var quickEntryTitle: String = ""
    @State private var captureText: String = ""
    @State private var captureStatus: TaskStatus = .todo
    @State private var captureTags: String = ""
    @State private var captureFeedback: String?
    @State private var completionFeedback: String?
    @State private var completionCount: Int = 0
    @State private var undoToast: String?
    @FocusState private var isQuickEntryFocused: Bool
    @FocusState private var isCaptureFocused: Bool
    @State private var hideDone: Bool = false
    @State private var statusFilter: TaskStatus? = nil
    @State private var tagFilter: Set<String> = []
    @State private var searchText: String = ""
    @State private var editorDraft: TaskEditorDraft = .init()
    @State private var editorTargetID: TaskItem.ID?
    @State private var isEditorPresented: Bool = false
    @State private var showShortcutsGuide: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                leftColumn
                    .frame(maxWidth: 720)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 48)
            }
            .frame(maxWidth: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))
            .navigationTitle("")
            .searchable(text: $searchText, prompt: "Search tasks")
            .overlay(alignment: .bottom) {
                VStack(spacing: 12) {
                    // Undo toast (higher priority)
                    if let undo = undoToast {
                        HStack(spacing: 12) {
                            Text(undo)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.primary)

                            Button(action: {
                                undoManager?.undo()
                                undoToast = nil
                            }) {
                                Text("Undo")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(nsColor: .controlBackgroundColor))
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(101)
                    }

                    // Completion celebration
                    if let completion = completionFeedback {
                        Text(completion)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.green.gradient)
                                    .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(100)
                    }
                }
                .padding(.bottom, 32)
            }
            .animation(AppAnimation.springStandard, value: completionFeedback)
            .animation(AppAnimation.springStandard, value: undoToast)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    if overdueCount > 0 {
                        Button(action: {
                            selectedView = .today
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                                Text("\(overdueCount) overdue")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.red)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.12))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .help("View overdue tasks")
                        .transition(.scale.combined(with: .opacity))
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: startBlankTask) {
                        Label("New Task", systemImage: "square.and.pencil")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                    .help("Create a new task (⌘N)")
                }
            }
        }
        .sheet(isPresented: $isEditorPresented, onDismiss: {
            editorTargetID = nil
        }) {
            TaskComposerSheet(draft: $editorDraft,
                             availableTags: availableTags,
                             isEditing: editorTargetID != nil,
                             onCancel: cancelEditor,
                             onSave: saveEditorChanges)
        }
        .sheet(isPresented: $showShortcutsGuide) {
            KeyboardShortcutsGuide()
        }
        .background(
            VStack {
                // Hidden buttons for keyboard shortcuts
                Button("Quick Capture") { isQuickEntryFocused = true }
                    .keyboardShortcut("k", modifiers: .command)
                    .hidden()

                Button("Switch to Today") { selectedView = .today }
                    .keyboardShortcut("t", modifiers: .command)
                    .hidden()

                Button("Switch to Inbox") { selectedView = .inbox }
                    .keyboardShortcut("1", modifiers: .command)
                    .hidden()

                Button("Switch to Board") { selectedView = .board }
                    .keyboardShortcut("2", modifiers: .command)
                    .hidden()

                Button("Clear Filters") {
                    statusFilter = nil
                    tagFilter.removeAll()
                    hideDone = false
                }
                .keyboardShortcut(.escape)
                .hidden()

                Button("Shortcuts Guide") { showShortcutsGuide = true }
                    .keyboardShortcut("/", modifiers: .command)
                    .hidden()
            }
        )
        .onAppear {
            addSampleDataIfNeeded()
        }
    }

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 16) {
                // Minimal view switcher
                HStack(spacing: 8) {
                    ForEach(ViewType.allCases, id: \.self) { viewType in
                        Button(action: { selectedView = viewType }) {
                            Text(viewType.rawValue)
                                .font(.system(size: 15, weight: selectedView == viewType ? .semibold : .regular))
                                .foregroundStyle(selectedView == viewType ? .primary : .secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(selectedView == viewType ? Color.primary.opacity(0.08) : Color.clear)
                                )
                                .animation(AppAnimation.quick, value: selectedView == viewType)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()

                // Task count
                if selectedView == .today && todayTasks.count > 0 {
                    HStack(spacing: 6) {
                        if overdueCount > 0 {
                            Text("\(overdueCount) overdue")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.red.opacity(0.1))
                                )
                        }
                        Text("\(todayTasks.count) task\(todayTasks.count == 1 ? "" : "s") due")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                } else if selectedView == .inbox && tasks.count > 0 {
                    HStack(spacing: 6) {
                        Text("\(tasks.filter { $0.status == .done }.count) of \(tasks.count) completed")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                } else if selectedView == .board && boardTasks.count > 0 {
                    HStack(spacing: 6) {
                        Text("This week: \(boardTasks.count) tasks")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var leftColumn: some View {
        VStack(alignment: .leading, spacing: 48) {
            pageHeader

            if selectedView == .today {
                todayView
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            } else if selectedView == .inbox {
                inboxView
                    .transition(.opacity)
            } else {
                boardView
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(AppAnimation.standard, value: selectedView)
    }

    private var inboxView: some View {
        VStack(alignment: .leading, spacing: 48) {
            TaskCaptureCard(quickEntryTitle: $quickEntryTitle,
                            captureText: $captureText,
                            captureStatus: $captureStatus,
                            captureTags: $captureTags,
                            onQuickAdd: addQuickTask,
                            onDumpAdd: captureTasks,
                            onClearDump: { captureText = "" },
                            feedback: captureFeedback,
                            quickEntryFocus: $isQuickEntryFocused,
                            captureFocus: $isCaptureFocused)

            FiltersCard(hideDone: $hideDone,
                        statusFilter: $statusFilter,
                        availableTags: availableTags,
                        activeTags: tagFilter,
                        toggleTag: toggleFilterTag,
                        clearTags: { tagFilter.removeAll() },
                        tasks: tasks)

            TasksListCard(tasks: filteredTasks,
                          updateStatus: { task, status in updateStatus(for: task, to: status) },
                          editTask: beginEditing,
                          deleteTask: delete,
                          toggleBoard: toggleBoard)
                .animation(AppAnimation.standard, value: filteredTasks.map { $0.id })
        }
    }

    private var todayView: some View {
        VStack(alignment: .leading, spacing: 48) {
            TaskCaptureCard(quickEntryTitle: $quickEntryTitle,
                            captureText: $captureText,
                            captureStatus: $captureStatus,
                            captureTags: $captureTags,
                            onQuickAdd: addQuickTask,
                            onDumpAdd: captureTasks,
                            onClearDump: { captureText = "" },
                            feedback: captureFeedback,
                            quickEntryFocus: $isQuickEntryFocused,
                            captureFocus: $isCaptureFocused)

            TodayTasksView(tasks: todayTasks,
                          overdueCount: overdueCount,
                          updateStatus: { task, status in updateStatus(for: task, to: status) },
                          editTask: beginEditing,
                          deleteTask: delete,
                          toggleBoard: toggleBoard)
        }
    }

    private var boardView: some View {
        VStack(spacing: 32) {
            // Weekly recurring tasks view
            if hasRecurringTasks {
                RecurringTasksWeekView(
                    tasks: recurringTasks,
                    editTask: beginEditing,
                    updateStatus: { task, status in updateStatus(for: task, to: status) }
                )

                Divider()
            }

            // Original kanban board (non-recurring tasks only)
            MinimalKanbanBoard(tasks: boardTasks,
                               updateStatus: { task, status in updateStatus(for: task, to: status) },
                               editTask: beginEditing,
                               deleteTask: delete,
                               toggleBoard: toggleBoard)
        }
    }

    private var availableTags: [String] {
        let unique = Set(tasks.flatMap(\.tags))
        return unique.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var orderedTasks: [TaskItem] {
        tasks.sorted { lhs, rhs in
            let lhsIndex = TaskStatus.allCases.firstIndex(of: lhs.status) ?? 0
            let rhsIndex = TaskStatus.allCases.firstIndex(of: rhs.status) ?? 0
            if lhsIndex == rhsIndex {
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
            return lhsIndex < rhsIndex
        }
    }

    private var filteredTasks: [TaskItem] {
        orderedTasks
            .filter { hideDone == false || $0.status != .done }
            .filter { statusFilter == nil || $0.status == statusFilter }
            .filter { tagFilter.isEmpty || !$0.tags.filter { tagFilter.contains($0) }.isEmpty }
            .filter { searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.details.localizedCaseInsensitiveContains(searchText) }
    }

    private var boardTasks: [TaskItem] {
        orderedTasks.filter { $0.isOnBoard && $0.recurrence == .none }
    }

    private var recurringTasks: [TaskItem] {
        tasks.filter { $0.recurrence != .none && $0.isOnBoard }
    }

    private var hasRecurringTasks: Bool {
        !recurringTasks.isEmpty
    }

    private var todayTasks: [TaskItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return orderedTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDay = calendar.startOfDay(for: dueDate)
            // Include tasks due today or overdue
            return taskDay <= today
        }
    }

    private var overdueTasks: [TaskItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDay = calendar.startOfDay(for: dueDate)
            return taskDay < today && task.status != .done
        }
    }

    private var overdueCount: Int {
        overdueTasks.count
    }

    private func parseTags(from string: String) -> [String] {
        string
            .components(separatedBy: CharacterSet(charactersIn: ",;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func extractSmartData(from text: String) -> (title: String, url: URL?, tags: [String]) {
        var workingText = text
        var extractedURL: URL?
        var extractedTags: [String] = []

        // Extract URLs
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let detector = detector {
            let matches = detector.matches(in: workingText, range: NSRange(workingText.startIndex..., in: workingText))
            if let match = matches.first, let range = Range(match.range, in: workingText) {
                let urlString = String(workingText[range])
                extractedURL = URL(string: urlString) ?? URL(string: "https://\(urlString)")
                workingText.removeSubrange(range)
            }
        }

        // Extract #hashtags
        let hashtagPattern = "#(\\w+)"
        if let regex = try? NSRegularExpression(pattern: hashtagPattern) {
            let matches = regex.matches(in: workingText, range: NSRange(workingText.startIndex..., in: workingText))
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: workingText) {
                    extractedTags.append(String(workingText[range]))
                }
                if let fullRange = Range(match.range, in: workingText) {
                    workingText.removeSubrange(fullRange)
                }
            }
        }

        let cleanTitle = workingText.trimmingCharacters(in: .whitespacesAndNewlines)
        return (cleanTitle, extractedURL, extractedTags)
    }

    private func addQuickTask() {
        let trimmed = quickEntryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let (cleanTitle, autoURL, autoTags) = extractSmartData(from: trimmed)
        let manualTags = parseTags(from: captureTags)
        let allTags = autoTags + manualTags

        let newTask = TaskItem(title: cleanTitle,
                               link: autoURL,
                               tags: allTags,
                               isOnBoard: true,
                               status: captureStatus)
        withAnimation(AppAnimation.springQuick) {
            modelContext.insert(newTask)
        }
        captureFeedback = "Added '\(cleanTitle)'"
        scheduleFeedbackClear()
        quickEntryTitle = ""
    }

    private func captureTasks() {
        let lines = captureText
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !lines.isEmpty else { return }

        let tags = parseTags(from: captureTags)
        let newTasks = lines.map { line in
            TaskItem(title: line,
                     tags: tags,
                     isOnBoard: true,
                     status: captureStatus)
        }

        withAnimation(AppAnimation.springQuick) {
            for task in newTasks {
                modelContext.insert(task)
            }
        }
        captureFeedback = "Captured \(newTasks.count) task\(newTasks.count == 1 ? "" : "s")"
        scheduleFeedbackClear()
        captureText = ""
        isCaptureFocused = true
    }

    private func toggleFilterTag(_ tag: String) {
        withAnimation(AppAnimation.quick) {
            if tagFilter.contains(tag) {
                tagFilter.remove(tag)
            } else {
                tagFilter.insert(tag)
            }
        }
    }

    private func startBlankTask() {
        editorDraft = TaskEditorDraft()
        editorTargetID = nil
        isEditorPresented = true
    }

    private func beginEditing(_ task: TaskItem) {
        editorDraft = TaskEditorDraft(task: task)
        editorTargetID = task.id
        isEditorPresented = true
    }

    private func saveEditorChanges() {
        guard editorDraft.linkIsValid else { return }
        guard !editorDraft.trimmedTitle.isEmpty else { return }
        guard editorDraft.recurrence == .none || editorDraft.dayOfWeek != nil else { return }

        if let targetID = editorTargetID,
           let existingTask = tasks.first(where: { $0.id == targetID }) {
            // Update existing task
            let updatedTask = editorDraft.makeTask(existingID: targetID)
            withAnimation(AppAnimation.standard) {
                existingTask.title = updatedTask.title
                existingTask.details = updatedTask.details
                existingTask.link = updatedTask.link
                existingTask.dueDate = updatedTask.dueDate
                existingTask.scheduledDate = updatedTask.scheduledDate
                existingTask.dayOfWeek = updatedTask.dayOfWeek
                existingTask.tags = updatedTask.tags
                existingTask.isOnBoard = updatedTask.isOnBoard
                existingTask.status = updatedTask.status
                existingTask.recurrence = updatedTask.recurrence
            }
        } else {
            // Insert new task
            let newTask = editorDraft.makeTask(existingID: nil)
            withAnimation(AppAnimation.springStandard) {
                modelContext.insert(newTask)
            }
        }

        isEditorPresented = false
        editorTargetID = nil
    }

    private func cancelEditor() {
        isEditorPresented = false
        editorTargetID = nil
    }

    private func updateStatus(for task: TaskItem, to status: TaskStatus) {
        // Track completions for celebration
        if status == .done && task.status != .done {
            completionCount += 1
            showCompletionCelebration()
        }

        // Handle recurring tasks when marked as done
        if status == .done && task.recurrence != .none, let currentDue = task.dueDate {
            if let nextDue = task.recurrence.nextDueDate(from: currentDue) {
                // Create new instance for next occurrence
                let newTask = TaskItem(
                    title: task.title,
                    details: task.details,
                    link: task.link,
                    dueDate: nextDue,
                    tags: task.tags,
                    isOnBoard: task.isOnBoard,
                    status: .todo,
                    recurrence: task.recurrence
                )

                withAnimation(AppAnimation.springStandard) {
                    // Remove the completed task
                    modelContext.delete(task)
                    // Add the new recurring instance
                    modelContext.insert(newTask)
                }
                return
            }
        }

        // Normal status update for non-recurring tasks
        withAnimation(AppAnimation.standard) {
            task.status = status
        }
    }

    private func showCompletionCelebration() {
        let messages = [
            "Great work!",
            "Task complete!",
            "Well done!",
            "Nice!",
            "Awesome!",
            "Keep it up!",
            "You're on fire! 🔥",
            "Crushing it!",
            "Way to go!"
        ]

        let streakMessages = [
            3: "3 in a row! 🎯",
            5: "5 tasks done! Amazing! ⭐",
            10: "10 tasks! You're unstoppable! 🚀",
            20: "20 tasks! Incredible! 🎉"
        ]

        if let streakMessage = streakMessages[completionCount] {
            completionFeedback = streakMessage
        } else {
            completionFeedback = messages.randomElement()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(AppAnimation.standard) {
                completionFeedback = nil
            }
        }
    }

    private func delete(_ task: TaskItem) {
        // Show undo toast
        undoToast = "Task deleted"
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(AppAnimation.standard) {
                undoToast = nil
            }
        }

        withAnimation(AppAnimation.standard) {
            modelContext.delete(task)
        }
    }

    private func delete(indices: IndexSet) {
        let ids = indices.compactMap { filteredTasks[$0].id }
        ids.forEach { id in
            if let task = tasks.first(where: { $0.id == id }) {
                delete(task)
            }
        }
    }

    private func scheduleFeedbackClear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(AppAnimation.standard) {
                captureFeedback = nil
            }
        }
    }

    private func toggleBoard(_ task: TaskItem) {
        withAnimation(AppAnimation.springStandard) {
            task.isOnBoard.toggle()
        }
    }

    private func scheduleTask(_ task: TaskItem, for date: Date) {
        withAnimation(AppAnimation.standard) {
            task.scheduledDate = date
            task.isOnBoard = true
        }
    }

    private func addSampleDataIfNeeded() {
        // Only add sample data if database is empty
        guard tasks.isEmpty else { return }

        let sampleTasks = [
            TaskItem(title: "Sketch project outline",
                     details: "Rough breakdown of milestones and key deliverables for the next sprint.",
                     tags: ["planning"],
                     isOnBoard: true),
            TaskItem(title: "Follow up with design",
                     details: "Send Figma file and confirm feedback meeting.",
                     dueDate: Calendar.current.date(byAdding: .day, value: 0, to: .now),
                     tags: ["communications"],
                     isOnBoard: true,
                     status: .inProgress),
            TaskItem(title: "Review pull requests",
                     details: "Check team PRs and provide feedback.",
                     dueDate: Calendar.current.date(byAdding: .day, value: -2, to: .now),
                     tags: ["development"],
                     isOnBoard: true,
                     status: .todo),
            TaskItem(title: "Book weekly review time",
                     dueDate: Calendar.current.date(byAdding: .day, value: 0, to: .now),
                     tags: ["planning"],
                     isOnBoard: true,
                     status: .todo)
        ]

        for task in sampleTasks {
            modelContext.insert(task)
        }
    }
}
