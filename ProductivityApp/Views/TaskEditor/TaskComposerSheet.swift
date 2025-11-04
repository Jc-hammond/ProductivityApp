//
//  TaskComposerSheet.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI

struct TaskComposerSheet: View {
    @Binding var draft: TaskEditorDraft
    let availableTags: [String]
    let isEditing: Bool
    let onCancel: () -> Void
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var inputText: String = ""
    @State private var parsedData: ParsedTaskData?
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    // Main input field
                    VStack(alignment: .leading, spacing: 12) {
                        ZStack(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("What needs to be done?")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }

                            TextEditor(text: $inputText)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.primary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 80, maxHeight: 120)
                                .focused($isInputFocused)
                                .onChange(of: inputText) { _, newValue in
                                    parsedData = NaturalLanguageTaskParser.parse(newValue)
                                    applyParsedData()
                                }
                        }

                        // Preview chips with smooth animation
                        if let parsed = parsedData, hasAnyParsedData(parsed) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    if let dateText = parsed.detectedDateText {
                                        PreviewChip(icon: "calendar", text: dateText)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    if parsed.recurrence != .none, let recText = parsed.detectedRecurrenceText {
                                        PreviewChip(icon: "repeat", text: recText)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    ForEach(parsed.tags, id: \.self) { tag in
                                        PreviewChip(icon: "number", text: tag)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    if parsed.link != nil {
                                        PreviewChip(icon: "link", text: "Link")
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                            }
                            .animation(AppAnimation.quick, value: parsed.detectedDateText)
                            .animation(AppAnimation.quick, value: parsed.recurrence)
                            .animation(AppAnimation.quick, value: parsed.tags)
                            .animation(AppAnimation.quick, value: parsed.link)
                        }
                    }

                    Divider()

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        TextEditor(text: $draft.details)
                            .font(.system(size: 15))
                            .scrollContentBackground(.hidden)
                            .frame(height: 80)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(nsColor: .controlBackgroundColor))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1)
                            )
                    }

                    // Due Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Due Date")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        HStack {
                            Toggle("", isOn: $draft.hasDueDate)
                                .labelsHidden()
                            if draft.hasDueDate {
                                DatePicker("", selection: $draft.dueDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Text("No due date")
                                    .foregroundStyle(.secondary)
                                    .transition(.opacity)
                            }
                            Spacer()
                        }
                        .animation(AppAnimation.quick, value: draft.hasDueDate)
                    }

                    // Scheduled Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Schedule for")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        HStack {
                            Toggle("", isOn: $draft.hasScheduledDate)
                                .labelsHidden()
                            if draft.hasScheduledDate {
                                DatePicker("", selection: $draft.scheduledDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Text("Not scheduled")
                                    .foregroundStyle(.secondary)
                                    .transition(.opacity)
                            }
                            Spacer()
                        }
                        .animation(AppAnimation.quick, value: draft.hasScheduledDate)
                    }

                    // Repeat
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Repeat")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Picker("Repeat", selection: $draft.recurrence) {
                            ForEach(TaskRecurrencePattern.allCases) { pattern in
                                Text(pattern.rawValue).tag(pattern)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }

                    // Day of Week (only shown if recurring)
                    if draft.recurrence != .none {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Day of Week")
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                            Picker("Day of Week", selection: Binding(
                                get: { draft.dayOfWeek ?? 1 },
                                set: { draft.dayOfWeek = $0 }
                            )) {
                                Text("Sunday").tag(1)
                                Text("Monday").tag(2)
                                Text("Tuesday").tag(3)
                                Text("Wednesday").tag(4)
                                Text("Thursday").tag(5)
                                Text("Friday").tag(6)
                                Text("Saturday").tag(7)
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Status
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Picker("Status", selection: $draft.status) {
                            ForEach(TaskStatus.allCases) { status in
                                Text(status.title).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }
                }
                .padding(32)
            }
            .background(Color(nsColor: .windowBackgroundColor))
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .keyboardShortcut(.return)
                    .animation(AppAnimation.quick, value: inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isInputFocused = true
            if isEditing {
                inputText = draft.title
            }
        }
        .background(
            Button("Cancel") { onCancel() }
                .keyboardShortcut(.escape)
                .hidden()
        )
    }

    private func hasAnyParsedData(_ parsed: ParsedTaskData) -> Bool {
        parsed.detectedDateText != nil ||
        parsed.recurrence != .none ||
        !parsed.tags.isEmpty ||
        parsed.link != nil
    }

    private func applyParsedData() {
        guard let parsed = parsedData else {
            draft.title = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
            return
        }

        draft.title = parsed.cleanTitle.isEmpty ? inputText.trimmingCharacters(in: .whitespacesAndNewlines) : parsed.cleanTitle
        draft.tags = parsed.tags
        draft.recurrence = parsed.recurrence

        if let dueDate = parsed.dueDate {
            draft.hasDueDate = true
            draft.dueDate = dueDate
        }

        if let link = parsed.link {
            draft.link = link.absoluteString
        }
    }
}
