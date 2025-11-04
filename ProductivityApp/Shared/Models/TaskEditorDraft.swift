//
//  TaskEditorDraft.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import Foundation

struct TaskEditorDraft {
    var title: String = ""
    var details: String = ""
    var link: String = ""
    var hasDueDate: Bool = false
    var dueDate: Date = Date()
    var hasScheduledDate: Bool = false
    var scheduledDate: Date = Date()
    var dayOfWeek: Int? = 1 // 1=Sunday, 2=Monday, ..., 7=Saturday
    var tags: [String] = []
    var isOnBoard: Bool = true
    var status: TaskStatus = .todo
    var recurrence: TaskRecurrencePattern = .none

    init() { }

    init(task: TaskItem) {
        self.title = task.title
        self.details = task.details
        self.link = task.link?.absoluteString ?? ""
        if let due = task.dueDate {
            self.hasDueDate = true
            self.dueDate = due
        }
        if let scheduled = task.scheduledDate {
            self.hasScheduledDate = true
            self.scheduledDate = scheduled
        }
        self.dayOfWeek = task.dayOfWeek
        self.tags = task.tags
        self.isOnBoard = task.isOnBoard
        self.status = task.status
        self.recurrence = task.recurrence
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var linkIsValid: Bool {
        let trimmed = link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        return resolvedLink(from: trimmed) != nil
    }

    var normalizedTags: [String] {
        var seen: Set<String> = []
        return tags.compactMap { raw in
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            let key = trimmed.lowercased()
            guard seen.insert(key).inserted else { return nil }
            return trimmed
        }
    }

    func makeTask(existingID: TaskItem.ID? = nil) -> TaskItem {
        let resolvedID = existingID ?? UUID()
        let cleanTitle = trimmedTitle
        let cleanDetails = details.trimmingCharacters(in: .whitespacesAndNewlines)
        let linkString = link.trimmingCharacters(in: .whitespacesAndNewlines)
        let linkURL = linkString.isEmpty ? nil : resolvedLink(from: linkString)
        let finalDueDate = hasDueDate ? dueDate : nil
        let finalScheduledDate = hasScheduledDate ? scheduledDate : nil
        var finalStatus = status
        let finalOnBoard = isOnBoard
        if finalOnBoard == false {
            finalStatus = .todo
        }

        return TaskItem(id: resolvedID,
                        title: cleanTitle,
                        details: cleanDetails,
                        link: linkURL,
                        dueDate: finalDueDate,
                        scheduledDate: finalScheduledDate,
                        dayOfWeek: dayOfWeek,
                        tags: normalizedTags,
                        isOnBoard: finalOnBoard,
                        status: finalStatus,
                        recurrence: recurrence)
    }

    private func resolvedLink(from string: String) -> URL? {
        if let url = URL(string: string), url.scheme != nil {
            return url
        }
        if let url = URL(string: "https://\(string)") {
            return url
        }
        return nil
    }
}
