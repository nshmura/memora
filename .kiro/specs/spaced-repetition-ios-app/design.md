# Design Document

## Overview

忘却曲線に基づく学習アプリのiOS MVPは、SwiftUIを使用したネイティブアプリとして実装します。MVVM + Repository パターンを採用し、ローカルデータ保存とローカル通知に特化したシンプルな設計とします。中学生でも理解できるよう、各レイヤーの責務を明確に分離し、GitHub Copilotでの段階的実装を支援する構造にします。

## Architecture

### レイヤー構成

```
┌─────────────────┐
│   Views Layer   │  SwiftUI Views + ViewModels
├─────────────────┤
│  Domain Layer   │  Business Logic (Scheduler, NotificationPlanner)
├─────────────────┤
│  Models Layer   │  Data Models (Card, Settings, ReviewLog)
├─────────────────┤
│   Store Layer   │  Data Persistence (JSON File I/O)
└─────────────────┘
```

### 主要コンポーネント

- **Views**: SwiftUI画面とViewModel（Home, Study, Cards, Settings）
- **Domain**: ビジネスロジック（Scheduler, NotificationPlanner）
- **Models**: データ構造（Card, Settings, ReviewLog）
- **Store**: データ永続化（JSONファイル読み書き）

## Components and Interfaces

### 1. Views Layer

#### HomeView + HomeViewModel
- 今日の復習枚数表示
- 連続学習日数表示
- 学習開始ボタン
- 次回通知予定表示

#### StudyView + StudyViewModel
- カード表示（問題→回答）
- 正誤ボタン
- 進捗表示
- 学習完了処理

#### CardsView + CardsViewModel
- カード一覧表示
- カード追加・編集
- 検索・フィルタ機能

#### SettingsView + SettingsViewModel
- 同日リトライON/OFF
- 通知時刻設定（0-23時）
- 間隔テーブル表示（編集は将来拡張）

### 2. Domain Layer

#### Scheduler
```swift
class Scheduler {
    static func gradeCard(_ card: Card, isCorrect: Bool, at date: Date) -> Card
    static func calculateNextDue(stepIndex: Int, baseDate: Date) -> Date
    static func startOfDay(for date: Date, in timeZone: TimeZone) -> Date
}
```

#### NotificationPlanner
```swift
class NotificationPlanner {
    func requestAuthorization() async -> Bool
    func scheduleMorningReminder(at hour: Int, cardCount: Int)
    func reorganizeNotifications()
}
```

### 3. Models Layer

#### Card
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

#### Settings
```swift
struct Settings: Codable {
    var intervals: [Int] = [0, 1, 2, 4, 7, 15, 30]
    var morningHour: Int = 8
    var timeZoneIdentifier: String = "Asia/Tokyo"
}
```

#### ReviewLog
```swift
struct ReviewLog: Codable, Identifiable {
    let id: UUID
    let cardId: UUID
    let reviewedAt: Date
    let previousStep: Int
    let nextStep: Int
    let result: Bool
    let latencyMs: Int
}
```

### 4. Store Layer

#### Store
```swift
class Store: ObservableObject {
    @Published var cards: [Card] = []
    @Published var settings: Settings = Settings()
    @Published var reviewLogs: [ReviewLog] = []
    
    func loadData()
    func saveCards()
    func saveSettings()
    func saveReviewLogs()
}
```

## Data Models

### JSONファイル構造

#### cards.json
```json
[
  {
    "id": "uuid-string",
    "question": "問題文",
    "answer": "回答",
    "stepIndex": 0,
    "nextDue": "2024-01-15T00:00:00Z",
    "reviewCount": 5,
    "lastResult": true,
    "tags": ["数学", "基礎"]
  }
]
```

#### settings.json
```json
{
  "intervals": [0, 1, 2, 4, 7, 15, 30],
  "morningHour": 8,
  "timeZoneIdentifier": "Asia/Tokyo"
}
```

#### reviewLogs.json
```json
[
  {
    "id": "uuid-string",
    "cardId": "card-uuid",
    "reviewedAt": "2024-01-15T09:30:00Z",
    "previousStep": 1,
    "nextStep": 2,
    "result": true,
    "latencyMs": 3500
  }
]
```

### Core Dataへの移行設計

将来的にCore Dataに移行する場合：
1. `Store`プロトコルを定義
2. `JSONStore`と`CoreDataStore`で実装
3. 依存性注入でストア実装を切り替え
4. データマイグレーション機能を追加

## Error Handling

### エラー分類と対応

#### データ保存エラー
- JSONファイル書き込み失敗 → ユーザーに通知、メモリ上のデータは保持
- ディスク容量不足 → 警告表示、古いログファイル削除提案

#### 通知エラー
- 権限未許可 → アプリ内バナーで代替案内
- 64件制限到達 → 古い通知削除、重要度順で再編成
- システム通知失敗 → ログ記録、次回起動時に再試行

#### 日付計算エラー
- タイムゾーン変更 → 設定値で強制JST計算
- システム時刻異常 → 前回保存時刻との差分チェック

#### UI/UXエラー
- ネットワーク不要のため通信エラーなし
- メモリ不足 → 大量データの遅延読み込み
- バックグラウンド復帰 → データ再読み込み

## Testing Strategy

### Unit Tests

#### Scheduler Tests
```swift
class SchedulerTests: XCTestCase {
    func testCorrectAnswerAdvancesStep()
    func testIncorrectAnswerResetsStep()
    func testDateBoundaryCalculation()
    func testJSTTimeZoneHandling()
    func testSameDayRetryLogic()
}
```

#### NotificationPlanner Tests
```swift
class NotificationPlannerTests: XCTestCase {
    func testMorningReminderScheduling()
    func testRetryNotificationScheduling()
    func test64NotificationLimit()
    func testNotificationReorganization()
}
```

#### Store Tests
```swift
class StoreTests: XCTestCase {
    func testJSONSaveAndLoad()
    func testDataMigration()
    func testConcurrentAccess()
    func testCorruptedFileRecovery()
}
```

### Integration Tests

#### End-to-End Scenarios
1. **新規ユーザーフロー**: アプリ初回起動 → カード追加 → 学習 → 通知設定
2. **日次学習フロー**: 朝の通知 → アプリ起動 → 復習 → 次回予約
3. **エラー回復フロー**: 権限拒否 → 代替案内 → 設定変更 → 再許可

#### UI Tests
- 各画面の基本操作
- 画面遷移の正常性
- アクセシビリティ要素の存在確認
- Dynamic Type対応確認

### Performance Tests
- 大量カード（1000枚）での動作確認
- 通知大量予約時の処理時間測定
- メモリ使用量監視

## アクセシビリティ設計

### Dynamic Type対応
```swift
Text("問題文")
    .font(.title2)
    .dynamicTypeSize(.large...accessibility1)
```

### VoiceOver対応
```swift
Button("正解") {
    // action
}
.accessibilityLabel("この回答は正解です")
.accessibilityHint("タップして次の問題に進みます")
```

### カラーコントラスト
- WCAG AA準拠の色彩設計
- ダークモード対応
- 色覚多様性への配慮

## ローカライズ設計

### 文言管理
```
Localizable.strings (ja)
"study.start" = "学習を始める";
"notification.morning" = "今日の復習 %d枚";

Localizable.strings (en)  
"study.start" = "Start Study";
"notification.morning" = "Today's Review: %d cards";
```

### 日付・時刻表示
- `DateFormatter`でロケール対応
- 相対日付表示（"明日", "3日後"）
- 24時間/12時間表示の自動切り替え

## 通知システム詳細設計

### 通知ID命名規約
- 朝の通知: `morning-reminder`
- リトライ通知: `retry-{cardId}`

### 64件制限対応アルゴリズム
1. 現在の予約通知数を取得
2. 60件を超える場合、古い順に削除
3. 新しい通知を予約
4. 重要度順（朝の通知 > 直近のリトライ）で優先順位付け

### 通知コンテンツ設計
```swift
let content = UNMutableNotificationContent()
content.title = "復習の時間です"
content.body = "今日の復習 \(cardCount)枚"
content.sound = .default
content.badge = NSNumber(value: cardCount)
```

## 画面ワイヤーフレーム

### Home画面
```
 ----------------------------
 |   Memora          2025/09/14 |
 ----------------------------
 | 今日の復習         |
 |      12枚          |
 |                    |
 | 🔥 連続日数 5日      |
 |                    |
 |  [ 学習を始める ]   |
 ----------------------------
 | 次回通知: 明日8:00   |
 ----------------------------
 TabBar: [Home] [Study] [Cards] [Settings]
```

### Study画面
```
 ----------------------------
 | 3 / 12                  |
 ----------------------------
 | 問題: 「関ヶ原の戦いは何年？」 |
 |                          |
 | [ 答えを入力する欄      ] |
 | [ Submit ▶︎ ]             |
 ----------------------------
 | 正解: 1600年             | ← Submit後に表示
 ----------------------------
 | [ 🤔 分からない ] [ ❌ 不正解 ] [ ✅ 正解 ] |
 ----------------------------
 TabBar: [Home] [Study] [Cards] [Settings]
```

### Cards画面
```
 ----------------------------
 | カード一覧                |
 ----------------------------
 | Q: りんごは英語で？       |
 | A: apple                 |
 ----------------------------
 | Q: 首都はどこ？           |
 | A: 東京                  |
 ----------------------------
 [+] 新規カード追加
 ----------------------------
 TabBar: [Home] [Study] [Cards] [Settings]
```

### Settings画面
```
 ----------------------------
 | 設定                      |
 ----------------------------
 | 通知時刻:      [ 08:00 ]   |
 ----------------------------
 | 間隔テーブル:             |
 | 0,1,2,4,7,15,30日         |
 (編集不可、将来拡張用)       |
 ----------------------------
 | アプリ情報 [Memoraについて] |
 ----------------------------
 TabBar: [Home] [Study] [Cards] [Settings]
```