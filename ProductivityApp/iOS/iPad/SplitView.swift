//
//  SplitView.swift
//  ProductivityApp (iOS - iPad)
//
//  iPad split view with sidebar navigation
//

import SwiftUI
import SwiftData

struct iPad_SplitView: View {
    @State private var selectedView: ViewType = .today

    enum ViewType {
        case today, inbox, board
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedView) {
                Label("Today", systemImage: "sun.max.fill")
                    .tag(ViewType.today)

                Label("Inbox", systemImage: "tray.fill")
                    .tag(ViewType.inbox)

                Label("Board", systemImage: "rectangle.3.group.fill")
                    .tag(ViewType.board)
            }
            .navigationTitle("Productivity")
        } detail: {
            // Detail view based on selection
            Group {
                switch selectedView {
                case .today:
                    iPhone_TodayView()
                case .inbox:
                    iPhone_InboxView()
                case .board:
                    iPhone_BoardView()
                }
            }
        }
    }
}
