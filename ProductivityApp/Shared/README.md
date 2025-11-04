# Shared Code

This folder contains code shared between macOS, iOS (iPhone), and iOS (iPad) targets.

## Structure

### Models/
Platform-independent data models used by all targets:
- `TaskItem.swift` - Main task model with SwiftData
- `TaskStatus.swift` - Task status enum (cross-platform colors)
- `TaskRecurrencePattern.swift` - Recurrence patterns
- `TaskEditorDraft.swift` - Draft state for task editing
- `ParsedTaskData.swift` - Natural language parse results
- `ViewType.swift` - View selection enum

### Utilities/
Shared utilities and design system:
- `DesignSystem.swift` - Cross-platform design tokens (colors, typography, spacing)
- `AppAnimation.swift` - Animation presets
- `NaturalLanguageTaskParser.swift` - Parse task input

### Sync/
CloudKit synchronization:
- `CloudKitSync.swift` - CloudKit sync manager for cross-device sync

## Target Membership

All files in this folder should be added to **both**:
- ✅ ProductivityApp (macOS)
- ✅ ProductivityApp-iOS (iOS)

## Platform-Specific Code

Files in this folder use `#if os()` conditionals for platform differences:

```swift
#if os(macOS)
    // macOS-specific code
    Color(nsColor: .systemBlue)
#else
    // iOS-specific code
    Color(uiColor: .systemBlue)
#endif
```

This allows maximum code reuse while respecting platform conventions.
