//
//  TaskRecurrencePattern.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import Foundation

enum TaskRecurrencePattern: String, CaseIterable, Identifiable, Codable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }

    func nextDueDate(from date: Date) -> Date? {
        guard self != .none else { return nil }
        let calendar = Calendar.current

        switch self {
        case .none:
            return nil
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date)
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date)
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date)
        }
    }
}
