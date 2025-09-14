# Implement Next Task

You are implementing a spaced repetition iOS app following a spec-driven development approach.

## Instructions

1. **Read the current task list** from `.kiro/specs/spaced-repetition-ios-app/tasks.md`
2. **Find the next uncompleted task** (marked with `- [ ]`)
3. **Review the requirements** referenced in the task's `_Requirements:` section from `.kiro/specs/spaced-repetition-ios-app/requirements.md`
4. **Check the design specifications** from `.kiro/specs/spaced-repetition-ios-app/design.md` for architecture and data models
5. **Implement only that specific task** - do not implement multiple tasks at once
6. **Follow the project structure** defined in the design document
7. **Write unit tests** if the task involves business logic (Domain layer)
8. **Use the coding patterns** from `.github/copilot-instructions.md`

## Implementation Rules

- **One task only**: Focus on the current task, don't jump ahead
- **Follow architecture**: Maintain MVVM + Repository pattern
- **JST timezone**: Always use "Asia/Tokyo" for date calculations
- **JSON storage**: Use Documents directory with Codable
- **Error handling**: Never crash the app, use graceful fallbacks
- **Test coverage**: Add unit tests for Scheduler, Store, and NotificationPlanner classes

## File Structure to Follow

```
SpacedStudy/
├─ App/SpacedStudyApp.swift
├─ Views/[ViewName].swift
├─ Domain/[BusinessLogic].swift  
├─ Models/[DataModel].swift
├─ Store/Store.swift
└─ Tests/[Component]Tests.swift
```

## Success Criteria

- [ ] Task implementation matches the requirements
- [ ] Code follows Swift/SwiftUI best practices
- [ ] Unit tests pass (if applicable)
- [ ] No compilation errors
- [ ] Follows the wireframe design (for UI tasks)

## Output Format

1. **Task Summary**: State which task you're implementing
2. **Requirements Check**: List the requirements being addressed
3. **Implementation**: Show the code changes
4. **Testing**: Include unit tests if needed
5. **Verification**: Confirm the task is complete

Start by identifying the next uncompleted task from the task list.