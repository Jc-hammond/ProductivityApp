//
//  TaskComposerSheet.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//  Enhanced with Design System
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
                VStack(alignment: .leading, spacing: AppSpacing.xxxl) {
                    // Main input field - larger and more prominent
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        ZStack(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("What needs to be done?")
                                    .font(AppTypography.composerInput)
                                    .foregroundStyle(AppColors.Text.placeholder)
                                    .padding(.top, AppSpacing.sm)
                                    .padding(.leading, AppSpacing.xs)
                            }

                            TextEditor(text: $inputText)
                                .font(AppTypography.composerInput)
                                .foregroundStyle(AppColors.Text.primary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100, maxHeight: 140)
                                .focused($isInputFocused)
                                .onChange(of: inputText) { _, newValue in
                                    parsedData = NaturalLanguageTaskParser.parse(newValue)
                                    applyParsedData()
                                }
                        }

                        // Preview chips with smooth animation - more refined
                        if let parsed = parsedData, hasAnyParsedData(parsed) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.sm) {
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
                            .animation(AppAnimation.springQuick, value: parsed.detectedDateText)
                            .animation(AppAnimation.springQuick, value: parsed.recurrence)
                            .animation(AppAnimation.springQuick, value: parsed.tags)
                            .animation(AppAnimation.springQuick, value: parsed.link)
                        }
                    }

                    Divider()
                        .background(AppColors.Border.divider)

                    // Notes - refined
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Notes")
                            .font(AppTypography.calloutEmphasis)
                            .foregroundStyle(AppColors.Text.secondary)
                        TextEditor(text: $draft.details)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.Text.primary)
                            .scrollContentBackground(.hidden)
                            .frame(height: 100)
                            .padding(AppSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .fill(AppColors.Surface.secondary)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .strokeBorder(AppColors.Border.subtle, lineWidth: 1)
                            )
                    }

                    // Due Date - refined
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Due Date")
                            .font(AppTypography.calloutEmphasis)
                            .foregroundStyle(AppColors.Text.secondary)
                        HStack(spacing: AppSpacing.md) {
                            Toggle("", isOn: $draft.hasDueDate)
                                .labelsHidden()
                            if draft.hasDueDate {
                                DatePicker("", selection: $draft.dueDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Text("No due date")
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.Text.tertiary)
                                    .transition(.opacity)
                            }
                            Spacer()
                        }
                        .animation(AppAnimation.springQuick, value: draft.hasDueDate)
                    }

                    // Scheduled Date - refined
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Schedule for")
                            .font(AppTypography.calloutEmphasis)
                            .foregroundStyle(AppColors.Text.secondary)
                        HStack(spacing: AppSpacing.md) {
                            Toggle("", isOn: $draft.hasScheduledDate)
                                .labelsHidden()
                            if draft.hasScheduledDate {
                                DatePicker("", selection: $draft.scheduledDate, displayedComponents: [.date])
                                    .labelsHidden()
                                    .transition(.scale.combined(with: .opacity))
                            } else {
                                Text("Not scheduled")
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.Text.tertiary)
                                    .transition(.opacity)
                            }
                            Spacer()
                        }
                        .animation(AppAnimation.springQuick, value: draft.hasScheduledDate)
                    }

                    // Repeat - refined
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Repeat")
                            .font(AppTypography.calloutEmphasis)
                            .foregroundStyle(AppColors.Text.secondary)
                        Picker("Repeat", selection: $draft.recurrence) {
                            ForEach(TaskRecurrencePattern.allCases) { pattern in
                                Text(pattern.rawValue).tag(pattern)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }

                    // Day of Week (only shown if recurring) - refined
                    if draft.recurrence != .none {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Day of Week")
                                .font(AppTypography.calloutEmphasis)
                                .foregroundStyle(AppColors.Text.secondary)
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

                    // Status - refined
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Status")
                            .font(AppTypography.calloutEmphasis)
                            .foregroundStyle(AppColors.Text.secondary)
                        Picker("Status", selection: $draft.status) {
                            ForEach(TaskStatus.allCases) { status in
                                Text(status.title).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }
                }
                .padding(AppSpacing.xxxl)
            }
            .background(AppColors.Surface.primary)
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(AppTypography.body)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                    .font(AppTypography.bodyEmphasis)
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .keyboardShortcut(.return)
                    .animation(AppAnimation.springQuick, value: inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(minWidth: 600, minHeight: 700)
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
