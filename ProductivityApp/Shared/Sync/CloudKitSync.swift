//
//  CloudKitSync.swift
//  ProductivityApp (Shared)
//
//  CloudKit synchronization foundation
//  Syncs TaskItem records across Mac, iPhone, and iPad
//

import Foundation
import CloudKit
import SwiftData

/// CloudKit sync manager for ProductivityApp
/// Handles bidirectional sync between local SwiftData and CloudKit
class CloudKitSyncManager: ObservableObject {
    // MARK: - Properties

    /// CloudKit container
    private let container: CKContainer

    /// Private database (user's personal data)
    private let privateDatabase: CKDatabase

    /// Record type name in CloudKit
    private static let recordType = "TaskRecord"

    /// Sync state
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?

    // MARK: - Initialization

    init(containerIdentifier: String = "iCloud.com.productivity.ProductivityApp") {
        self.container = CKContainer(identifier: containerIdentifier)
        self.privateDatabase = container.privateCloudDatabase
    }

    // MARK: - Public API

    /// Sync all tasks to CloudKit
    func syncToCloud(tasks: [TaskItem]) async throws {
        await MainActor.run { isSyncing = true }
        defer { Task { await MainActor.run { isSyncing = false } } }

        var records: [CKRecord] = []

        for task in tasks {
            let record = try createRecord(from: task)
            records.append(record)
        }

        // Batch save to CloudKit
        try await saveRecords(records)

        await MainActor.run {
            lastSyncDate = Date()
        }
    }

    /// Fetch changes from CloudKit
    func fetchFromCloud() async throws -> [TaskItem] {
        await MainActor.run { isSyncing = true }
        defer { Task { await MainActor.run { isSyncing = false } } }

        let query = CKQuery(recordType: Self.recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "modifiedAt", ascending: false)]

        let results = try await privateDatabase.records(matching: query)

        var tasks: [TaskItem] = []

        for (_, result) in results.matchResults {
            switch result {
            case .success(let record):
                if let task = try createTask(from: record) {
                    tasks.append(task)
                }
            case .failure(let error):
                print("Error fetching record: \(error)")
            }
        }

        await MainActor.run {
            lastSyncDate = Date()
        }

        return tasks
    }

    // MARK: - Record Conversion

    /// Convert TaskItem to CKRecord
    private func createRecord(from task: TaskItem) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: task.id.uuidString)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)

        record["title"] = task.title as CKRecordValue
        record["details"] = task.details as CKRecordValue
        record["link"] = (task.link?.absoluteString ?? "") as CKRecordValue
        record["dueDate"] = task.dueDate as CKRecordValue?
        record["scheduledDate"] = task.scheduledDate as CKRecordValue?
        record["dayOfWeek"] = (task.dayOfWeek ?? 0) as CKRecordValue
        record["tags"] = task.tags as CKRecordValue
        record["isOnBoard"] = (task.isOnBoard ? 1 : 0) as CKRecordValue
        record["status"] = task.status.rawValue as CKRecordValue
        record["recurrence"] = task.recurrence.rawValue as CKRecordValue
        record["modifiedAt"] = Date() as CKRecordValue

        return record
    }

    /// Convert CKRecord to TaskItem
    private func createTask(from record: CKRecord) throws -> TaskItem? {
        guard let title = record["title"] as? String else { return nil }

        let details = record["details"] as? String ?? ""
        let linkString = record["link"] as? String ?? ""
        let link = linkString.isEmpty ? nil : URL(string: linkString)
        let dueDate = record["dueDate"] as? Date
        let scheduledDate = record["scheduledDate"] as? Date
        let dayOfWeek = record["dayOfWeek"] as? Int
        let tags = record["tags"] as? [String] ?? []
        let isOnBoard = (record["isOnBoard"] as? Int ?? 0) == 1

        let statusRaw = record["status"] as? String ?? "todo"
        let status = TaskStatus(rawValue: statusRaw) ?? .todo

        let recurrenceRaw = record["recurrence"] as? String ?? "none"
        let recurrence = TaskRecurrencePattern(rawValue: recurrenceRaw) ?? .none

        // Parse UUID from record name
        guard let uuid = UUID(uuidString: record.recordID.recordName) else { return nil }

        return TaskItem(
            id: uuid,
            title: title,
            details: details,
            link: link,
            dueDate: dueDate,
            scheduledDate: scheduledDate,
            dayOfWeek: dayOfWeek,
            tags: tags,
            isOnBoard: isOnBoard,
            status: status,
            recurrence: recurrence
        )
    }

    // MARK: - CloudKit Operations

    /// Save records to CloudKit with batching
    private func saveRecords(_ records: [CKRecord]) async throws {
        // CloudKit limits operations to 400 records
        let batchSize = 400
        let batches = stride(from: 0, to: records.count, by: batchSize).map {
            Array(records[$0..<min($0 + batchSize, records.count)])
        }

        for batch in batches {
            let operation = CKModifyRecordsOperation(recordsToSave: batch, recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.qualityOfService = .userInitiated

            try await privateDatabase.add(operation)
        }
    }

    // MARK: - Conflict Resolution

    /// Resolve conflicts using Last Write Wins strategy
    func resolveConflict(local: TaskItem, remote: CKRecord) -> TaskItem {
        // TODO: Implement proper LWW with modifiedAt timestamps
        // For now, prefer remote (cloud) version
        if let remoteTask = try? createTask(from: remote) {
            return remoteTask
        }
        return local
    }
}

// MARK: - TaskItem Extensions for CloudKit

extension TaskItem {
    /// Convenience initializer for CloudKit deserialization
    convenience init(
        id: UUID,
        title: String,
        details: String,
        link: URL?,
        dueDate: Date?,
        scheduledDate: Date?,
        dayOfWeek: Int?,
        tags: [String],
        isOnBoard: Bool,
        status: TaskStatus,
        recurrence: TaskRecurrencePattern
    ) {
        self.init(
            title: title,
            details: details,
            link: link,
            dueDate: dueDate,
            scheduledDate: scheduledDate,
            dayOfWeek: dayOfWeek,
            tags: tags,
            isOnBoard: isOnBoard,
            status: status,
            recurrence: recurrence
        )
        // Note: SwiftData may regenerate ID, additional sync logic needed
    }
}
