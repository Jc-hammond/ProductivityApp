//
//  TaskStatus.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI

enum TaskStatus: String, CaseIterable, Identifiable, Codable {
    case todo
    case inProgress
    case done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .todo: return "To Do"
        case .inProgress: return "In Progress"
        case .done: return "Done"
        }
    }

    var accentColor: Color {
        switch self {
        case .todo:
            #if os(macOS)
            return Color(nsColor: .systemBlue)
            #else
            return Color(uiColor: .systemBlue)
            #endif
        case .inProgress:
            #if os(macOS)
            return Color(nsColor: .systemOrange)
            #else
            return Color(uiColor: .systemOrange)
            #endif
        case .done:
            #if os(macOS)
            return Color(nsColor: .systemGreen)
            #else
            return Color(uiColor: .systemGreen)
            #endif
        }
    }

    var iconName: String {
        switch self {
        case .todo: return "circle"
        case .inProgress: return "clock"
        case .done: return "checkmark.circle.fill"
        }
    }
}

extension TaskStatus {
    var nextStep: TaskStatus? {
        switch self {
        case .todo: return .inProgress
        case .inProgress: return .done
        case .done: return nil
        }
    }
}
