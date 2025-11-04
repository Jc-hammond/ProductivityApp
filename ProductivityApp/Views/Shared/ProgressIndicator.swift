//
//  ProgressIndicator.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import SwiftUI

struct ProgressIndicator: View {
    let tasks: [TaskItem]

    private var completedCount: Int {
        tasks.filter { $0.status == .done }.count
    }

    private var totalCount: Int {
        tasks.count
    }

    private var progress: Double {
        totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
    }

    private var progressPercentage: Int {
        Int(progress * 100)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.green)
                    Text("\(completedCount) of \(totalCount) completed")
                        .font(.system(size: 13, weight: .medium))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(colors: [
                                    Color.green.opacity(0.8),
                                    Color.green
                                ], startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geometry.size.width * progress, height: 6)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progress)
                    }
                }
                .frame(height: 6)
            }

            if progressPercentage > 0 {
                Text("\(progressPercentage)%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.green.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
}
