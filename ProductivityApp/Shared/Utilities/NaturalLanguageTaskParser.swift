//
//  NaturalLanguageTaskParser.swift
//  ProductivityApp
//
//  Created by Connor Hammond on 11/2/25.
//

import Foundation

class NaturalLanguageTaskParser {
    static func parse(_ input: String) -> ParsedTaskData {
        var workingText = input
        var detectedDate: Date?
        var detectedDateText: String?
        var detectedTags: [String] = []
        var detectedLink: URL?
        var detectedRecurrence: TaskRecurrencePattern = .none
        var detectedRecurrenceText: String?

        // Extract recurrence patterns first (before date parsing)
        let recurrencePatterns: [(pattern: String, recurrence: TaskRecurrencePattern)] = [
            ("every day|daily", .daily),
            ("every week|weekly", .weekly),
            ("every month|monthly", .monthly)
        ]

        for (pattern, recurrence) in recurrencePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: workingText, range: NSRange(workingText.startIndex..., in: workingText)),
               let range = Range(match.range, in: workingText) {
                detectedRecurrence = recurrence
                detectedRecurrenceText = String(workingText[range])
                workingText.removeSubrange(range)
                break
            }
        }

        // Extract URLs
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let matches = detector.matches(in: workingText, range: NSRange(workingText.startIndex..., in: workingText))
            if let match = matches.first, let range = Range(match.range, in: workingText) {
                let urlString = String(workingText[range])
                detectedLink = URL(string: urlString) ?? URL(string: "https://\(urlString)")
                workingText.removeSubrange(range)
            }
        }

        // Extract #hashtags
        let hashtagPattern = "#(\\w+)"
        if let regex = try? NSRegularExpression(pattern: hashtagPattern) {
            let matches = regex.matches(in: workingText, range: NSRange(workingText.startIndex..., in: workingText))
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: workingText) {
                    detectedTags.append(String(workingText[range]))
                }
                if let fullRange = Range(match.range, in: workingText) {
                    workingText.removeSubrange(fullRange)
                }
            }
        }

        // Extract dates and times
        let calendar = Calendar.current
        let now = Date()

        // Time patterns (extract first to combine with date)
        var detectedTime: (hour: Int, minute: Int)?
        let timePattern = "(?:at\\s+)?(\\d{1,2})(?::(\\d{2}))?\\s*(am|pm|AM|PM)?"
        if let regex = try? NSRegularExpression(pattern: timePattern),
           let match = regex.firstMatch(in: workingText, range: NSRange(workingText.startIndex..., in: workingText)),
           let hourRange = Range(match.range(at: 1), in: workingText) {

            var hour = Int(String(workingText[hourRange])) ?? 0
            var minute = 0

            if match.range(at: 2).location != NSNotFound,
               let minuteRange = Range(match.range(at: 2), in: workingText) {
                minute = Int(String(workingText[minuteRange])) ?? 0
            }

            if match.range(at: 3).location != NSNotFound,
               let ampmRange = Range(match.range(at: 3), in: workingText) {
                let ampm = String(workingText[ampmRange]).lowercased()
                if ampm == "pm" && hour < 12 {
                    hour += 12
                } else if ampm == "am" && hour == 12 {
                    hour = 0
                }
            }

            detectedTime = (hour, minute)
            if let fullRange = Range(match.range, in: workingText) {
                workingText.removeSubrange(fullRange)
            }
        }

        // Date patterns
        let datePatterns: [(pattern: String, dayOffset: Int?)] = [
            ("\\btoday\\b", 0),
            ("\\btomorrow\\b", 1),
            ("\\bnext week\\b", 7),
            ("\\bin (\\d+) days?\\b", nil)
        ]

        for (pattern, dayOffset) in datePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: workingText, range: NSRange(workingText.startIndex..., in: workingText)),
               let range = Range(match.range, in: workingText) {

                detectedDateText = String(workingText[range])

                let offset: Int
                if let dayOffset = dayOffset {
                    offset = dayOffset
                } else if match.numberOfRanges > 1,
                          let numberRange = Range(match.range(at: 1), in: workingText),
                          let days = Int(String(workingText[numberRange])) {
                    offset = days
                } else {
                    offset = 0
                }

                if let baseDate = calendar.date(byAdding: .day, value: offset, to: now) {
                    var components = calendar.dateComponents([.year, .month, .day], from: baseDate)
                    if let time = detectedTime {
                        components.hour = time.hour
                        components.minute = time.minute
                    }
                    detectedDate = calendar.date(from: components)
                }

                workingText.removeSubrange(range)
                break
            }
        }

        // Day of week patterns (e.g., "next friday")
        let weekdayPatterns = [
            ("monday", 2),
            ("tuesday", 3),
            ("wednesday", 4),
            ("thursday", 5),
            ("friday", 6),
            ("saturday", 7),
            ("sunday", 1)
        ]

        for (day, weekday) in weekdayPatterns {
            let pattern = "\\bnext\\s+\(day)\\b"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: workingText, range: NSRange(workingText.startIndex..., in: workingText)),
               let range = Range(match.range, in: workingText) {

                detectedDateText = String(workingText[range])

                var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: now)
                components.weekday = weekday
                components.weekOfYear! += 1

                if let baseDate = calendar.date(from: components) {
                    var finalComponents = calendar.dateComponents([.year, .month, .day], from: baseDate)
                    if let time = detectedTime {
                        finalComponents.hour = time.hour
                        finalComponents.minute = time.minute
                    }
                    detectedDate = calendar.date(from: finalComponents)
                }

                workingText.removeSubrange(range)
                break
            }
        }

        // Clean up extra whitespace
        let cleanTitle = workingText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)

        return ParsedTaskData(
            cleanTitle: cleanTitle,
            dueDate: detectedDate,
            tags: detectedTags,
            link: detectedLink,
            recurrence: detectedRecurrence,
            detectedDateText: detectedDateText,
            detectedRecurrenceText: detectedRecurrenceText
        )
    }
}
