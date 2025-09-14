# GitHub Copilot Instructions - Compact

## Quick Start
忘却曲線学習アプリ iOS MVP。SwiftUI + JSON storage。

## Core Rules
- **Tasks**: Follow `.kiro/specs/spaced-repetition-ios-app/tasks.md` order
- **CRITICAL**: Mark [x] completed tasks immediately in tasks.md
- **Architecture**: MVVM + Repository pattern
- **Build**: Always run `xcodebuild` verification
- **Tests**: Comprehensive unit tests required

## Key Patterns
```swift
// Models: Codable structs
struct Card: Codable, Identifiable { /* ... */ }

// JST dates
let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!

// JSON storage
private func saveToJSON<T: Codable>(_ data: T, filename: String) throws
```

## Workflow
1. Read current task → 2. Implement + test → 3. Build verify → 4. **Update tasks.md** → 5. Commit/push

**Never complete without tasks.md [x] update**
- ✅ JST timezone handling

### What to Exclude (Future)
- ❌ Cloud sync, Push notifications, Accessibility, Localization

## Success Criteria
- Add card → Study → Answer → Next due updates
- Morning notification works
- Wrong answer resets to step 0
- Data persists across restarts

## Quick Reference
- Spec files: `.kiro/specs/spaced-repetition-ios-app/`
- Next task: Check tasks.md 
- **Remember**: Always update tasks.md with [x]