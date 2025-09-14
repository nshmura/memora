# Setup iOS Project

You are setting up the initial Xcode project for a spaced repetition learning app.

## Instructions

1. **Review the project requirements** from `.kiro/specs/spaced-repetition-ios-app/requirements.md`
2. **Check the architecture design** from `.kiro/specs/spaced-repetition-ios-app/design.md`
3. **Follow the first task** in `.kiro/specs/spaced-repetition-ios-app/tasks.md` (Task 1: Project setup)
4. **Create the folder structure** as defined in the design document

## Project Configuration

### Xcode Project Settings
- **Project Name**: SpacedStudy
- **Bundle Identifier**: com.yourname.spacedStudy
- **Deployment Target**: iOS 16.0+
- **Interface**: SwiftUI
- **Language**: Swift

### Required Capabilities
- **Local Notifications**: Add to Info.plist
- **Background App Refresh**: For notification scheduling

### Folder Structure to Create
```
SpacedStudy/
├─ App/
│   └─ SpacedStudyApp.swift
├─ Views/
│   ├─ HomeView.swift
│   ├─ StudyView.swift  
│   ├─ CardsView.swift
│   └─ SettingsView.swift
├─ Domain/
│   ├─ Scheduler.swift
│   └─ NotificationPlanner.swift
├─ Models/
│   ├─ Card.swift
│   ├─ Settings.swift
│   └─ ReviewLog.swift
├─ Store/
│   └─ Store.swift
└─ Tests/
    ├─ SchedulerTests.swift
    └─ StoreTests.swift
```

### Info.plist Additions
```xml
<key>NSUserNotificationUsageDescription</key>
<string>This app needs notification permission to remind you of daily reviews.</string>
```

## Initial Files to Create

### SpacedStudyApp.swift
```swift
import SwiftUI

@main
struct SpacedStudyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Basic ContentView with TabView
```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Placeholder views for now
        }
    }
}
```

## Success Criteria

- [ ] Xcode project created with correct settings
- [ ] Folder structure matches design specification
- [ ] Info.plist configured for notifications
- [ ] Project compiles without errors
- [ ] Ready for Task 2 implementation

Create a clean, well-organized project foundation following iOS development best practices.