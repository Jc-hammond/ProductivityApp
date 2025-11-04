//
//  KeyboardShortcutsGuide.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI

struct KeyboardShortcutsGuide: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stay focused with keyboard shortcuts")
                            .font(.title2.weight(.semibold))
                        Text("Master these shortcuts to work faster and stay in flow.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)

                    ShortcutSection(title: "Quick Actions") {
                        ShortcutRow(key: "⌘K", description: "Focus quick capture field")
                        ShortcutRow(key: "⌘N", description: "Create new detailed task")
                        ShortcutRow(key: "⌘F", description: "Search tasks")
                        ShortcutRow(key: "Esc", description: "Clear all filters")
                    }

                    ShortcutSection(title: "Navigation") {
                        ShortcutRow(key: "⌘1", description: "Switch to Inbox view")
                        ShortcutRow(key: "⌘2", description: "Switch to Board view")
                    }

                    ShortcutSection(title: "Smart Input") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("In quick capture:")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            ShortcutRow(key: "#tag", description: "Auto-create tags with hashtags")
                            ShortcutRow(key: "URL", description: "Auto-detect and extract links")
                        }
                    }

                    ShortcutSection(title: "Context Menu") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Right-click any task to:")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text("• Edit, delete, or change status\n• Pin/unpin from board\n• Copy task title or link")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(32)
            }
            .navigationTitle("Keyboard Shortcuts")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 550)
    }
}
