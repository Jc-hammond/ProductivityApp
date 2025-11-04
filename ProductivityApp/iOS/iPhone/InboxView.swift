//
//  InboxView.swift
//  ProductivityApp (iOS - iPhone)
//
//  Full inbox view for iPhone
//

import SwiftUI
import SwiftData

struct iPhone_InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]

    @State private var searchText = ""
    @State private var statusFilter: TaskStatus? = nil
    @State private var hideDone = false

    private var filteredTasks: [TaskItem] {
        tasks
            .filter { hideDone == false || $0.status != .done }
            .filter { statusFilter == nil || $0.status == statusFilter }
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
            .sorted { lhs, rhs in
                let lhsIndex = TaskStatus.allCases.firstIndex(of: lhs.status) ?? 0
                let rhsIndex = TaskStatus.allCases.firstIndex(of: rhs.status) ?? 0
                return lhsIndex < rhsIndex
            }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    // Filter chips
                    if !tasks.isEmpty {
                        filterSection
                    }

                    // Task list
                    if filteredTasks.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: AppSpacing.sm) {
                            ForEach(filteredTasks) { task in
                                iPhone_TaskRow(task: task)
                            }
                        }
                    }
                }
                .padding(AppSpacing.lg)
                .padding(.bottom, 80) // Space for FAB
            }
            .background(AppColors.Surface.primary)
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search tasks")
        }
    }

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    // Hide done toggle
                    Button(action: { hideDone.toggle() }) {
                        Label("Hide Done", systemImage: hideDone ? "eye.slash.fill" : "eye.fill")
                            .font(AppTypography.caption)
                    }
                    .buttonStyle(.bordered)
                    .tint(hideDone ? AppColors.Status.done : .gray)

                    Divider()
                        .frame(height: 20)

                    // Status filters
                    ForEach(TaskStatus.allCases) { status in
                        Button(action: { toggleStatusFilter(status) }) {
                            HStack(spacing: AppSpacing.xs) {
                                Circle()
                                    .fill(status.accentColor)
                                    .frame(width: 8, height: 8)
                                Text(status.title)
                                    .font(AppTypography.caption)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(statusFilter == status ? status.accentColor : .gray)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundStyle(AppColors.Text.tertiary)

            Text(searchText.isEmpty ? "No tasks yet" : "No matching tasks")
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.Text.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.massive)
    }

    private func toggleStatusFilter(_ status: TaskStatus) {
        withAnimation(AppAnimation.springQuick) {
            if statusFilter == status {
                statusFilter = nil
            } else {
                statusFilter = status
            }
        }
    }
}
