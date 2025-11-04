//
//  TaskEditorSheet.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI

struct TaskEditorSheet: View {
    @Binding var draft: TaskEditorDraft
    let availableTags: [String]
    let isEditing: Bool
    let onCancel: () -> Void
    let onSave: () -> Void

    @State private var newTagText: String = ""

    private var tagSuggestions: [String] {
        let assigned = Set(draft.tags.map { $0.lowercased() })
        return availableTags.filter { !assigned.contains($0.lowercased()) }
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .controlBackgroundColor).opacity(0.5),
                    Color(nsColor: .controlBackgroundColor)
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

                Form {
                    Section("Basics") {
                        TextField("Title", text: $draft.title, prompt: Text("What needs to be done?"))
                            .textFieldStyle(.roundedBorder)
                        TextField("Link (optional)", text: $draft.link, prompt: Text("https://example.com/resource"))
                            .textFieldStyle(.roundedBorder)
                        if draft.linkIsValid == false {
                            Label("Link must be a valid URL", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                                .font(.footnote)
                        }
                    }

                    Section("Description") {
                        TextEditor(text: $draft.details)
                            .frame(minHeight: 140)
                    }

                    Section("Due Date") {
                        Toggle("Set due date", isOn: $draft.hasDueDate)
                        if draft.hasDueDate {
                            DatePicker("Due", selection: $draft.dueDate, displayedComponents: [.date])
                        }
                    }

                    Section("Recurrence") {
                        Picker("Repeat", selection: $draft.recurrence) {
                            ForEach(TaskRecurrencePattern.allCases) { pattern in
                                Text(pattern.rawValue).tag(pattern)
                            }
                        }
                        .pickerStyle(.segmented)

                        if draft.recurrence != .none && !draft.hasDueDate {
                            Label("Recurring tasks require a due date", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                                .font(.footnote)
                        }
                    }

                    Section("Tags") {
                        if draft.tags.isEmpty {
                            Text("No tags yet")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(draft.tags.enumerated()), id: \.offset) { index, tag in
                                HStack {
                                    Text(tag)
                                    Spacer()
                                    Button(role: .destructive) {
                                        draft.tags.remove(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            TextField("Add tag", text: $newTagText)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit(commitNewTag)
                            Button("Add", action: commitNewTag)
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .disabled(newTagText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }

                        if !tagSuggestions.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(tagSuggestions, id: \.self) { suggestion in
                                        Button(suggestion) {
                                            appendTag(suggestion)
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                    }
                                }
                            }
                        }
                    }

                    Section("Status") {
                        Picker("Status", selection: $draft.status) {
                            ForEach(TaskStatus.allCases) { status in
                                Text(status.title).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .formStyle(.grouped)
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: onSave)
                        .disabled(draft.trimmedTitle.isEmpty || draft.linkIsValid == false)
                }
            }
        }
        .frame(minWidth: 520, minHeight: 520)
    }

    private func commitNewTag() {
        let parts = newTagText
            .components(separatedBy: CharacterSet(charactersIn: ",;"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !parts.isEmpty else { return }
        for part in parts {
            appendTag(part)
        }
        newTagText = ""
    }

    private func appendTag(_ tag: String) {
        guard !draft.tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) else { return }
        draft.tags.append(tag)
    }
}
