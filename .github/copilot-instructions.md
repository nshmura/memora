# GitHub Copilot Instructions for Spaced Repetition iOS App

## Project Overview
忘却曲線に基づく学習アプリのiOS MVPを実装します。SwiftUIを使用し、ローカルデータ保存とローカル通知に特化したシンプルな設計です。

## Development Guidelines

### 1. Spec-Driven Development
- **必須**: 実装前に `.kiro/specs/spaced-repetition-ios-app/` の以下ファイルを参照してください
  - `requirements.md`: 要件とAcceptance Criteria
  - `design.md`: アーキテクチャとデータモデル
  - `tasks.md`: 実装タスクリスト
- **タスク実行**: tasks.mdの順序に従って1つずつ実装してください
- **要件確認**: 各タスクの _Requirements_ セクションで対応する要件を確認してください

### 2. Architecture Rules
```
Views Layer (SwiftUI + ViewModels)
├─ Domain Layer (Business Logic)
├─ Models Layer (Data Structures) 
└─ Store Layer (JSON Persistence)
```

- **MVVM Pattern**: ViewとViewModelを分離し、@ObservableObjectを活用
- **Repository Pattern**: Storeクラスでデータ永続化を抽象化
- **Dependency Injection**: ViewModelにStoreを注入する設計

### 3. Code Quality Standards

#### Swift/SwiftUI Best Practices
```swift
// ✅ Good: Clear naming and structure
struct HomeViewModel: ObservableObject {
    @Published var todayCardCount: Int = 0
    @Published var streakDays: Int = 0
    
    private let store: Store
    
    init(store: Store) {
        self.store = store
    }
}

// ✅ Good: Proper error handling
func loadCards() {
    do {
        cards = try store.loadCards()
    } catch {
        print("Failed to load cards: \(error)")
        // Handle gracefully
    }
}
```

#### File Organization
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

### 4. Implementation Rules

#### Data Models (Codable Required)
```swift
struct Card: Codable, Identifiable {
    let id: UUID
    var question: String
    var answer: String
    var stepIndex: Int
    var nextDue: Date
    var reviewCount: Int
    var lastResult: Bool?
    var tags: [String]
}
```

#### JST Timezone Handling
```swift
// Always use Asia/Tokyo for date calculations
let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!
let calendar = Calendar.current
calendar.timeZone = jstTimeZone
```

#### JSON Storage Pattern
```swift
// Documents directory + JSON files
private func getDocumentsDirectory() -> URL {
    FileManager.default.urls(for: .documentDirectory, 
                           in: .userDomainMask)[0]
}

private func saveToJSON<T: Codable>(_ data: T, filename: String) throws {
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    let jsonData = try JSONEncoder().encode(data)
    try jsonData.write(to: url)
}
```

#### Notification Handling
```swift
// Request permission after first study completion
func requestNotificationPermission() async -> Bool {
    let center = UNUserNotificationCenter.current()
    do {
        let granted = try await center.requestAuthorization(
            options: [.alert, .badge, .sound]
        )
        return granted
    } catch {
        return false
    }
}
```

### 5. Testing Requirements

#### Unit Tests (Required for each component)
```swift
class SchedulerTests: XCTestCase {
    func testCorrectAnswerAdvancesStep() {
        // Test stepIndex increment
    }
    
    func testIncorrectAnswerResetsStep() {
        // Test stepIndex = 0, nextDue = tomorrow
    }
    
    func testJSTDateBoundary() {
        // Test 23:59 JST boundary calculation
    }
}
```

#### Test Data
```swift
// Use consistent test data
let testCard = Card(
    id: UUID(),
    question: "テスト問題",
    answer: "テスト回答", 
    stepIndex: 0,
    nextDue: Date(),
    reviewCount: 0,
    lastResult: nil,
    tags: []
)
```

### 6. UI Implementation Guidelines

#### SwiftUI Structure
```swift
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Follow wireframe layout from design.md
            }
            .navigationTitle("Memora")
        }
    }
}
```

#### Wireframe Reference
- **Home**: 今日の復習枚数、連続日数、学習開始ボタン
- **Study**: 問題表示→回答入力→正誤判定（3択: 分からない/不正解/正解）
- **Cards**: カード一覧、追加・編集機能
- **Settings**: 通知時刻設定、間隔テーブル表示

### 7. Error Handling Strategy

#### Graceful Degradation
```swift
// ✅ Never crash the app
func loadSettings() -> Settings {
    do {
        return try store.loadSettings()
    } catch {
        print("Using default settings due to error: \(error)")
        return Settings() // Default values
    }
}
```

#### Notification Fallbacks
```swift
// Handle permission denied gracefully
if !notificationPermissionGranted {
    // Show in-app reminder instead
    showInAppReminder = true
}
```

### 8. Development Workflow

#### Step-by-Step Process
1. **Read Current Task**: Check tasks.md for next implementation step
2. **Review Requirements**: Check corresponding requirements in requirements.md
3. **Check Design**: Reference architecture and data models in design.md
4. **Implement**: Write minimal, working code
5. **Xcode Build**: **MANDATORY** - Run `xcodebuild` to verify compilation
6. **Test**: Add unit tests for business logic
7. **Verify**: Ensure task acceptance criteria are met

#### Mandatory Build Verification
```bash
# Must run after every task implementation
cd memora/
xcodebuild -project memora.xcodeproj -scheme memora \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.4' build
```
**Rule**: Never complete a task without successful Xcode build verification

#### Commit Messages
```
feat: implement Card model with Codable support (Task 2.1)
test: add Scheduler unit tests for JST boundary (Task 4.3)
ui: create HomeView with wireframe layout (Task 5.2)
```

### 9. MVP Constraints

#### What to Include
- ✅ 4 main screens (Home/Study/Cards/Settings)
- ✅ Local JSON storage
- ✅ Morning notification (8:00 AM)
- ✅ Spaced repetition algorithm [0,1,2,4,7,15,30] days
- ✅ JST timezone handling

#### What to Exclude (Future Extensions)
- ❌ Push notifications
- ❌ Cloud sync
- ❌ Accessibility features (Dynamic Type, VoiceOver)
- ❌ Localization (ja/en)
- ❌ Same-day retry notifications
- ❌ Advanced scheduling algorithms (FSRS, SM-2)

### 10. Success Criteria

#### Acceptance Tests
- [ ] Add card → Study → Answer correctly → Next due date updates
- [ ] Morning notification appears at set time
- [ ] Wrong answer resets stepIndex to 0, sets next due to tomorrow
- [ ] App works without notification permission
- [ ] Data persists across app restarts

#### Performance Targets
- App launch < 2 seconds
- Smooth UI animations
- Handle 1000+ cards without lag

---

## Quick Reference

### Key Files to Reference
- `.kiro/specs/spaced-repetition-ios-app/requirements.md` - What to build
- `.kiro/specs/spaced-repetition-ios-app/design.md` - How to build it  
- `.kiro/specs/spaced-repetition-ios-app/tasks.md` - Step-by-step tasks

### Current Task Status
Check tasks.md for the next uncompleted task and implement it following the requirements and design specifications.

### Need Help?
1. Check the spec files first
2. Reference the wireframes in design.md
3. Follow the architecture patterns shown above
4. Keep it simple - this is an MVP!