//
//  TabBarView.swift
//  ProductivityApp (iOS - iPhone)
//
//  Main tab bar navigation for iPhone
//

import SwiftUI
import SwiftData

struct iPhone_TabBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]

    @State private var selectedTab: TabSelection = .today
    @State private var showingComposer = false

    enum TabSelection {
        case today, inbox, board, more
    }

    private var todayCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return tasks.filter { task in
            guard let dueDate = task.dueDate, task.status != .done else { return false }
            let taskDay = calendar.startOfDay(for: dueDate)
            return taskDay <= today
        }.count
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            iPhone_TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .badge(todayCount > 0 ? todayCount : nil)
                .tag(TabSelection.today)

            iPhone_InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray.fill")
                }
                .tag(TabSelection.inbox)

            iPhone_BoardView()
                .tabItem {
                    Label("Board", systemImage: "rectangle.3.group.fill")
                }
                .tag(TabSelection.board)

            iPhone_MoreView()
                .tabItem {
                    Label("More", systemImage: "ellipsis.circle.fill")
                }
                .tag(TabSelection.more)
        }
        .tint(AppColors.Status.inProgress)
        .sheet(isPresented: $showingComposer) {
            iPhone_TaskComposerView()
        }
        .overlay(alignment: .bottomTrailing) {
            // Floating Action Button for quick capture
            if selectedTab != .more {
                Button(action: { showingComposer = true }) {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppColors.Status.inProgress, AppColors.Status.inProgress.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: AppColors.Status.inProgress.opacity(0.4), radius: 12, x: 0, y: 6)
                        )
                }
                .padding(.trailing, AppSpacing.xl)
                .padding(.bottom, 80) // Above tab bar
            }
        }
    }
}
