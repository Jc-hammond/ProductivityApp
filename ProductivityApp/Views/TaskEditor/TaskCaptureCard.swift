//
//  TaskCaptureCard.swift
//  ProductivityApp
//
//  Created on 2025-11-03.
//

import SwiftUI

struct TaskCaptureCard: View {
    @Binding var quickEntryTitle: String
    @Binding var captureText: String
    @Binding var captureStatus: TaskStatus
    @Binding var captureTags: String
    let onQuickAdd: () -> Void
    let onDumpAdd: () -> Void
    let onClearDump: () -> Void
    let feedback: String?
    let quickEntryFocus: FocusState<Bool>.Binding
    let captureFocus: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Clean, minimal quick capture
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .bottomTrailing) {
                    HStack(spacing: 8) {
                        TextField("What's on your mind?", text: $quickEntryTitle)
                            .textFieldStyle(.plain)
                            .font(.system(size: 17))
                            .focused(quickEntryFocus)
                            .onSubmit(onQuickAdd)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
                    )

                    // Floating feedback (no layout shift)
                    if let feedback {
                        Text(feedback)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.95))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                            )
                            .padding(8)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(AppAnimation.standard, value: feedback)

                // Subtle hint
                Text("Use #tags and paste URLs - they'll be auto-detected")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
            }
        }
    }
}
