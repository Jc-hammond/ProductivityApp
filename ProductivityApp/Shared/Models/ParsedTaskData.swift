//
//  ParsedTaskData.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import Foundation

struct ParsedTaskData {
    var cleanTitle: String
    var dueDate: Date?
    var tags: [String]
    var link: URL?
    var recurrence: TaskRecurrencePattern
    var detectedDateText: String?
    var detectedRecurrenceText: String?
}
