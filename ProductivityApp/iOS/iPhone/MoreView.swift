//
//  MoreView.swift
//  ProductivityApp (iOS - iPhone)
//
//  Settings and additional features
//

import SwiftUI

struct iPhone_MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(AppColors.Text.secondary)
                    }

                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(AppTypography.caption)
                                .foregroundStyle(AppColors.Text.tertiary)
                        }
                    }
                }

                Section("Sync") {
                    HStack {
                        Text("iCloud Sync")
                        Spacer()
                        Text("Coming Soon")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColors.Text.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        // TODO: Clear all data with confirmation
                    } label: {
                        Text("Clear All Data")
                    }
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
