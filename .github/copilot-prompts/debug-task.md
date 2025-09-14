# Debug Current Task

You are debugging issues in the spaced repetition iOS app implementation.

## Instructions

1. **Identify the problem** being reported or observed
2. **Check the current task context** from `.kiro/specs/spaced-repetition-ios-app/tasks.md`
3. **Review requirements** from `.kiro/specs/spaced-repetition-ios-app/requirements.md`
4. **Verify against design** from `.kiro/specs/spaced-repetition-ios-app/design.md`
5. **Apply debugging strategies** following `.github/copilot-instructions.md`

## Debugging Approach

### Common Issue Categories

#### Compilation Errors
- Missing imports
- Type mismatches
- Protocol conformance issues
- Access control problems

#### Runtime Issues
- Force unwrapping crashes
- JSON encoding/decoding failures
- Date/timezone calculation errors
- Notification permission problems

#### Logic Errors
- Incorrect spaced repetition algorithm
- Wrong date boundary calculations
- State management issues
- Navigation problems

#### UI Issues
- Layout problems
- State binding issues
- Navigation stack problems
- TabView configuration

## Debugging Steps

### 1. Error Analysis
```swift
// Check for common patterns:
// - Force unwrapping: someValue!
// - Unhandled optionals: let value = optional
// - Missing error handling: try someFunction()
```

### 2. JST Timezone Issues
```swift
// Ensure proper timezone handling:
let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!
var calendar = Calendar.current
calendar.timeZone = jstTimeZone
```

### 3. JSON Storage Problems
```swift
// Verify Codable implementation:
struct Card: Codable {
    // All properties must be Codable
}

// Check file paths:
let documentsPath = FileManager.default.urls(
    for: .documentDirectory, 
    in: .userDomainMask
)[0]
```

### 4. Notification Issues
```swift
// Check permission status:
let center = UNUserNotificationCenter.current()
let settings = await center.notificationSettings()
print("Authorization status: \(settings.authorizationStatus)")
```

### 5. State Management
```swift
// Verify @Published and @StateObject usage:
class ViewModel: ObservableObject {
    @Published var property: Type = defaultValue
}

struct View: View {
    @StateObject private var viewModel = ViewModel()
}
```

## Testing Strategy

### Unit Test Debugging
```swift
// Add debug prints in tests:
func testScheduler() {
    let result = scheduler.gradeCard(card, isCorrect: true, at: testDate)
    print("Expected: \(expectedDate), Got: \(result.nextDue)")
    XCTAssertEqual(result.nextDue, expectedDate)
}
```

### UI Debugging
```swift
// Add debug modifiers:
.onAppear {
    print("View appeared with state: \(viewModel.state)")
}
```

## Output Format

1. **Problem Identification**: What's the specific issue?
2. **Root Cause Analysis**: Why is this happening?
3. **Solution Strategy**: How to fix it?
4. **Code Changes**: Specific fixes to implement
5. **Prevention**: How to avoid similar issues
6. **Testing**: How to verify the fix works

## Common Fixes

### Date Boundary Issues
```swift
func startOfDay(for date: Date) -> Date {
    let jst = TimeZone(identifier: "Asia/Tokyo")!
    var calendar = Calendar.current
    calendar.timeZone = jst
    return calendar.startOfDay(for: date)
}
```

### JSON Encoding Issues
```swift
// Use ISO8601 for dates:
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
```

### Notification Scheduling
```swift
// Always check authorization:
guard await requestNotificationPermission() else {
    // Handle gracefully without crashing
    return
}
```

Focus on systematic debugging and provide clear, actionable solutions.