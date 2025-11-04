# 🎯 Xcode Target Setup Guide

## Quick Reference: Which Files Go Where

After opening the project in Xcode, ensure these files have the correct target membership:

### ✅ Both Targets (macOS + iOS)

**Models/** (6 files)
- [ ] TaskItem.swift
- [ ] TaskStatus.swift
- [ ] TaskRecurrencePattern.swift
- [ ] ViewType.swift
- [ ] TaskEditorDraft.swift
- [ ] ParsedTaskData.swift

**Utilities/** (3 files)
- [ ] DesignSystem.swift
- [ ] AppAnimation.swift
- [ ] NaturalLanguageTaskParser.swift

**Shared/Models/** (6 files - same as Models/)
- [ ] All files (these are copies for organization)

**Shared/Utilities/** (3 files - same as Utilities/)
- [ ] All files (these are copies for organization)

**Shared/Sync/** (1 file)
- [ ] CloudKitSync.swift

### 📱 iOS Target Only

**iOS/** (all files and subfolders)
- [ ] ProductivityApp_iOS.swift
- [ ] iPhone/TabBarView.swift
- [ ] iPhone/TodayView.swift
- [ ] iPhone/InboxView.swift
- [ ] iPhone/BoardView.swift
- [ ] iPhone/MoreView.swift
- [ ] iPhone/TaskComposerView.swift
- [ ] iPad/SplitView.swift
- [ ] Shared/TaskRow.swift

### 💻 macOS Target Only

**Everything in ProductivityApp/ root except Models/, Utilities/, Shared/, iOS/**
- [ ] ContentView.swift
- [ ] ProductivityAppApp.swift
- [ ] Views/Today/
- [ ] Views/Inbox/
- [ ] Views/Board/
- [ ] Views/Recurring/
- [ ] Views/Shared/
- [ ] Views/TaskEditor/
- [ ] Views/Help/

---

## How to Set Target Membership in Xcode

1. **Select a file** in Project Navigator
2. **Open File Inspector** (⌥⌘1 or View → Inspectors → File)
3. **Check the boxes** under "Target Membership":
   - ✅ ProductivityApp (for macOS)
   - ✅ ProductivityApp-iOS (for iOS)

---

## Verification Checklist

After setting up targets, verify:

### macOS Target
```bash
# Should compile successfully
Product → Build (⌘B)
# Select ProductivityApp scheme → macOS destination
```

### iOS Target
```bash
# Should compile successfully
Product → Build (⌘B)
# Select ProductivityApp-iOS scheme → iPhone 15 Pro
```

### Common Build Errors

**"No such module 'SwiftData'"**
- Check iOS Deployment Target is 17.0+
- Clean Build Folder (⇧⌘K)

**"Cannot find 'TaskItem' in scope"**
- Check TaskItem.swift is in iOS target membership
- Check import SwiftData is present

**"Cannot find type 'AppColors' in scope"**
- Check DesignSystem.swift is in iOS target membership

**"Use of unresolved identifier 'nsColor'"**
- This file needs platform conditionals (#if os(macOS))
- Already fixed in DesignSystem.swift and TaskStatus.swift

---

## File Organization Notes

### Why Two Copies?

You'll notice Models/ and Shared/Models/ have the same files. This is intentional:

- **Models/** - Original location (for backward compatibility with macOS)
- **Shared/Models/** - Organized location (better multiplatform structure)

In Xcode, you can:
- **Option A:** Use both (add both to targets)
- **Option B:** Delete Models/ and keep only Shared/Models/ (cleaner, but requires updating imports)

**Recommendation:** Use Option A for now (both exist), refactor later if desired.

---

## CloudKit Setup

After targets compile successfully:

1. Select **ProductivityApp-iOS** target
2. Go to **Signing & Capabilities**
3. Click **"+ Capability"**
4. Add **"iCloud"**
5. Check **"CloudKit"**
6. Container: `iCloud.com.yourcompany.ProductivityApp`
7. Repeat for **ProductivityApp** (macOS) target

---

## Testing the iOS App

### iPhone Simulator
1. Select scheme: **ProductivityApp-iOS**
2. Select destination: **iPhone 15 Pro**
3. Press ⌘R to run
4. App should launch with tab bar navigation

### iPad Simulator
1. Select scheme: **ProductivityApp-iOS**
2. Select destination: **iPad Pro (12.9-inch)**
3. Press ⌘R to run
4. App should launch with split view navigation

---

## Troubleshooting

### App crashes on launch
- Check SwiftData model container setup in ProductivityApp_iOS.swift
- Verify all models are in iOS target

### Views appear blank
- Check Query imports (`@Query private var tasks: [TaskItem]`)
- Verify modelContainer modifier is applied

### Colors look wrong
- DesignSystem.swift should have #if os() conditionals
- Check updated version is in both targets

---

*All code changes are complete and platform-aware. Just set up targets in Xcode!* ✨
