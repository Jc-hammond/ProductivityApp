//
//  ProductivityAppApp.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI
import SwiftData

@main
struct ProductivityAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1000, minHeight: 600)
        }
        .windowStyle(.automatic)
        .modelContainer(for: TaskItem.self)
    }
}
