//
//  BoardCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI
import SwiftData
import AppKit

struct BoardCard: View {
    let task: TaskItem
    let accent: Color
    let advanceStatus: () -> Void
    let toggleBoard: () -> Void

    @State private var hovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(task.title)
                .font(.system(size: 15, weight: .semibold))
                .lineSpacing(2)
            if !task.details.isEmpty {
                Text(task.details)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
            if let due = task.dueDate {
                DueBadge(date: due)
            }
            if let link = task.link {
                LinkBadge(url: link)
            }
            if !task.tags.isEmpty {
                TagChipsView(tags: task.tags, tint: accent)
            }

            HStack {
                Button(task.status == .done ? "Reset" : "Advance", action: advanceStatus)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .tint(accent)
                    .help(task.status == .done ? "Reset to To Do" : task.status == .todo ? "Move to In Progress" : "Mark as Done")
                Button("Unpin", role: .cancel, action: toggleBoard)
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Remove from board")
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(hovering ? 0.18 : 0.08), radius: hovering ? 18 : 10, x: 0, y: hovering ? 12 : 6)
        .scaleEffect(hovering ? 1.01 : 1)
        .animation(AppAnimation.standard, value: hovering)
        .onHover { hovering = $0 }
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .contextMenu {
            Button(action: advanceStatus) {
                if task.status == .done {
                    Label("Reset to To Do", systemImage: "arrow.counterclockwise")
                } else if task.status == .inProgress {
                    Label("Mark as Done", systemImage: "checkmark.circle.fill")
                } else {
                    Label("Move to In Progress", systemImage: "clock")
                }
            }

            Button(action: toggleBoard) {
                Label("Unpin from Board", systemImage: "pin.slash")
            }

            Divider()

            Button(action: {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(task.title, forType: .string)
            }) {
                Label("Copy Task Title", systemImage: "doc.on.doc")
            }

            if let link = task.link {
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(link.absoluteString, forType: .string)
                }) {
                    Label("Copy Link", systemImage: "link")
                }
            }
        }
    }
}
