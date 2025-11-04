# 📁 ProductivityApp Folder Structure

## Current Organization

This document describes the folder structure for the multiplatform ProductivityApp.

```
ProductivityApp/
│
├── iOS_MIGRATION_GUIDE.md          # Comprehensive iOS migration instructions
├── FOLDER_STRUCTURE.md              # This file
│
├── ProductivityApp/                 # Main project folder
│   │
│   ├── Shared/                      # ← Shared code (70%)
│   │   ├── Sync/
│   │   │   └── CloudKitSync.swift   # CloudKit synchronization
│   │   └── (Move models & utilities here in Xcode)
│   │
│   ├── iOS/                         # ← iOS-specific (15%)
│   │   ├── ProductivityApp_iOS.swift     # iOS app entry point
│   │   │
│   │   ├── iPhone/
│   │   │   ├── TabBarView.swift          # Main tab navigation
│   │   │   ├── TodayView.swift           # Today view for iPhone
│   │   │   ├── InboxView.swift           # Inbox view for iPhone
│   │   │   ├── BoardView.swift           # Board view for iPhone
│   │   │   ├── MoreView.swift            # Settings/More view
│   │   │   └── TaskComposerView.swift    # Full-screen task composer
│   │   │
│   │   ├── iPad/
│   │   │   └── SplitView.swift           # iPad split view navigation
│   │   │
│   │   └── Shared/
│   │       └── TaskRow.swift             # Swipeable task row component
│   │
│   ├── macOS/                       # ← macOS-specific (existing)
│   │   ├── ContentView.swift
│   │   ├── Views/
│   │   │   ├── Today/
│   │   │   ├── Inbox/
│   │   │   ├── Board/
│   │   │   ├── Recurring/
│   │   │   ├── Shared/
│   │   │   ├── TaskEditor/
│   │   │   └── Help/
│   │   └── ProductivityApp.swift    # Mac app entry point
│   │
│   ├── Models/                      # ← Should move to Shared/ in Xcode
│   │   ├── TaskItem.swift
│   │   ├── TaskStatus.swift
│   │   ├── TaskRecurrencePattern.swift
│   │   ├── ViewType.swift
│   │   ├── TaskEditorDraft.swift
│   │   └── ParsedTaskData.swift
│   │
│   └── Utilities/                   # ← Should move to Shared/ in Xcode
│       ├── DesignSystem.swift       # Platform-aware design system ✅
│       ├── AppAnimation.swift
│       └── NaturalLanguageTaskParser.swift
│
└── iOS Files Created:

iOS App Entry:
  ✅ ProductivityApp/iOS/ProductivityApp_iOS.swift

iPhone Views:
  ✅ ProductivityApp/iOS/iPhone/TabBarView.swift
  ✅ ProductivityApp/iOS/iPhone/TodayView.swift
  ✅ ProductivityApp/iOS/iPhone/InboxView.swift
  ✅ ProductivityApp/iOS/iPhone/BoardView.swift
  ✅ ProductivityApp/iOS/iPhone/MoreView.swift
  ✅ ProductivityApp/iOS/iPhone/TaskComposerView.swift

iPad Views:
  ✅ ProductivityApp/iOS/iPad/SplitView.swift

Shared iOS Components:
  ✅ ProductivityApp/iOS/Shared/TaskRow.swift

CloudKit Sync:
  ✅ ProductivityApp/Shared/Sync/CloudKitSync.swift

Design System:
  ✅ ProductivityApp/Utilities/DesignSystem.swift (updated for iOS)
```

---

## Next Steps in Xcode

### 1. Create iOS Target

1. Open `ProductivityApp.xcodeproj` in Xcode
2. Click project name → Click "+" in targets list
3. Select iOS → App → Name: "ProductivityApp-iOS"
4. Bundle ID: `com.yourcompany.ProductivityApp.iOS`

### 2. Add Files to iOS Target

For each file that should be shared:
1. Select the file in Project Navigator
2. Open File Inspector (⌥⌘1)
3. Under "Target Membership", check both:
   - ✅ ProductivityApp (macOS)
   - ✅ ProductivityApp-iOS

**Files to add to both targets:**
- All files in `Models/`
- All files in `Utilities/`
- All files in `Shared/`
- `iOS/` files only to iOS target

### 3. Reorganize Folders (Optional)

For better organization:
1. Create "Shared" group in Xcode
2. Drag `Models/` and `Utilities/` into it
3. Create "macOS" group
4. Drag macOS-specific views into it
5. Keep `iOS/` folder as is

---

## Platform-Specific Code

The app uses conditional compilation for platform differences:

```swift
#if os(macOS)
    // Mac-specific code
#else
    // iOS-specific code (iPhone + iPad)
#endif

#if os(iOS)
    // iOS-only code
import UIKit
#endif
```

**Examples:**
- `DesignSystem.swift` uses Dynamic Type on iOS
- Touch targets are 44pt minimum on iOS
- Haptic feedback only on iOS

---

## Target Membership Guide

| File/Folder | macOS Target | iOS Target |
|-------------|--------------|------------|
| `Models/` | ✅ | ✅ |
| `Utilities/` | ✅ | ✅ |
| `Shared/Sync/` | ✅ | ✅ |
| `macOS/` | ✅ | ❌ |
| `iOS/` | ❌ | ✅ |

---

## Build Settings

### iOS Target
- Deployment Target: iOS 17.0+
- Supported Destinations: iPhone, iPad
- Orientation: All (adjust in Info.plist)

### macOS Target
- Deployment Target: macOS 14.0+
- Destination: Mac (Apple Silicon, Intel)

---

## CloudKit Setup

1. Add iCloud capability to both targets
2. Enable CloudKit
3. Container: `iCloud.com.yourcompany.ProductivityApp`
4. Set up schema in CloudKit Dashboard (see iOS_MIGRATION_GUIDE.md)

---

*This structure provides a clean separation between platforms while maximizing code reuse.* ✨
