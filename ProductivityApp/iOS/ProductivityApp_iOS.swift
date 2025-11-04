//
//  ProductivityApp_iOS.swift
//  ProductivityApp (iOS)
//
//  iOS App Entry Point
//

import SwiftUI
import SwiftData

@main
struct ProductivityApp_iOS: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: TaskItem.self)
    }
}

struct RootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                // iPad in regular size class
                iPad_SplitView()
            } else {
                // iPhone or iPad in compact mode
                iPhone_TabBarView()
            }
        }
    }
}
