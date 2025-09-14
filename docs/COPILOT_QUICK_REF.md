# iOS Spaced Repetition App - Quick Reference

## Architecture
- **MVVM + Repository**: Views → ViewModels → Store → JSON files
- **Layers**: Views/Domain/Models/Store/Tests
- **Platform**: iOS 16+, SwiftUI, Local storage only

## Task Flow
1. Read next task from `.kiro/specs/spaced-repetition-ios-app/tasks.md`
2. Check requirements & design specs
3. Implement with tests
4. Run `xcodebuild` to verify
5. **MANDATORY**: Update tasks.md with [x] 
6. Commit & push

## Key Rules
- All models: `Codable` structs
- JST timezone: `Asia/Tokyo`
- JSON storage: Documents directory
- Test coverage: Business logic mandatory
- Never skip tasks.md update

## Critical Files
- `tasks.md`: Implementation checklist
- `requirements.md`: Acceptance criteria  
- `design.md`: Architecture & data models

**Current**: Task 3.1 (Store class) ready to implement
