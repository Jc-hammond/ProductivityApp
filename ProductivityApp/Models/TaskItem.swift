//
//  TaskItem.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import Foundation
import SwiftData

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var details: String
    var link: URL?
    var dueDate: Date?
    var scheduledDate: Date?
    var dayOfWeek: Int? // 1=Sunday, 2=Monday, ..., 7=Saturday
    var tags: [String]
    var isOnBoard: Bool
    var status: TaskStatus
    var recurrence: TaskRecurrencePattern

    init(id: UUID = UUID(),
         title: String,
         details: String = "",
         link: URL? = nil,
         dueDate: Date? = nil,
         scheduledDate: Date? = nil,
         dayOfWeek: Int? = nil,
         tags: [String] = [],
         isOnBoard: Bool = false,
         status: TaskStatus = .todo,
         recurrence: TaskRecurrencePattern = .none) {
        self.id = id
        self.title = title
        self.details = details
        self.link = link
        self.dueDate = dueDate
        self.scheduledDate = scheduledDate
        self.dayOfWeek = dayOfWeek
        self.tags = tags
        self.isOnBoard = isOnBoard
        self.status = status
        self.recurrence = recurrence
    }
}
