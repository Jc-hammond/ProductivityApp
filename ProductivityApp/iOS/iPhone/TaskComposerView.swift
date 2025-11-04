//
//  TaskComposerView.swift
//  ProductivityApp (iOS - iPhone)
//
//  Full-screen task composer optimized for iPhone
//

import SwiftUI
import SwiftData

struct iPhone_TaskComposerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var notes = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var status: TaskStatus = .todo
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What needs to be done?", text: $title, axis: .vertical)
                        .font(AppTypography.composerInput)
                        .focused($isTitleFocused)
                        .lineLimit(3...6)
                }

                Section("Details") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .font(AppTypography.body)
                        .lineLimit(4...8)
                }

                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker("Date", selection: $dueDate, displayedComponents: [.date])
                    }
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases) { status in
                            HStack {
                                Circle()
                                    .fill(status.accentColor)
                                    .frame(width: 10, height: 10)
                                Text(status.title)
                            }
                            .tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isTitleFocused = true
        }
    }

    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let task = TaskItem(
            title: trimmedTitle,
            details: notes,
            dueDate: hasDueDate ? dueDate : nil,
            tags: [],
            isOnBoard: true,
            status: status
        )

        withAnimation(AppAnimation.springStandard) {
            modelContext.insert(task)
        }

        #if os(iOS)
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif

        dismiss()
    }
}
