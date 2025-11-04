//
//  DueBadge.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI

struct DueBadge: View {
    let date: Date

    private var info: (text: String, icon: String, color: Color) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDay = calendar.startOfDay(for: date)
        if dueDay < today {
            return ("Overdue · \(date.formatted(date: .abbreviated, time: .omitted))",
                    "calendar.badge.exclamationmark",
                    Color(nsColor: .systemRed))
        }
        if calendar.isDateInToday(date) {
            return ("Due today", "sunrise.fill", Color(nsColor: .systemOrange))
        }
        if let soon = calendar.date(byAdding: .day, value: 2, to: today),
           dueDay <= soon {
            return ("Due soon · \(date.formatted(date: .abbreviated, time: .omitted))",
                    "clock.badge.exclamationmark",
                    Color(nsColor: .systemOrange))
        }
        return ("Due \(date.formatted(date: .abbreviated, time: .omitted))",
                "calendar",
                Color(nsColor: .secondaryLabelColor))
    }

    var body: some View {
        Label(info.text, systemImage: info.icon)
            .font(.system(size: 12, weight: .semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .foregroundStyle(info.color)
            .background(
                LinearGradient(colors: [
                    info.color.opacity(0.18),
                    info.color.opacity(0.05)
                ], startPoint: .topLeading, endPoint: .bottomTrailing),
                in: Capsule()
            )
    }
}
