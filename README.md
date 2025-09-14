# Memora - 忘却曲線学習アプリ

忘却曲線に基づく間隔反復学習を行うiOS MVPアプリです。SwiftUIを使用し、ローカルデータ保存とローカル通知に特化したシンプルな設計になっています。

## 📱 アプリ概要

### 主要機能
- **4画面構成**: Home / Study / Cards / Settings
- **間隔反復**: [0,1,2,4,7,15,30]日の固定間隔テーブル
- **ローカル通知**: 毎朝8:00の復習リマインダー
- **ファイルアプリ対応**: JSONファイルによるデータ永続化（ファイルアプリからアクセス可能）
- **JST対応**: 日本時間での正確な日付境界処理
- **無料アカウント対応**: Apple Developer Program不要でファイル管理

### 対象ユーザー
- 初学者（中学生レベル）でも理解できるシンプルな設計
- GitHub Copilotを活用した段階的実装が可能

## 🏗️ 開発アプローチ

### Spec-Driven Development
このプロジェクトはKiroのSpec機能を使用して設計されています：

```
.kiro/specs/spaced-repetition-ios-app/
├── requirements.md  # 要件定義（EARS形式）
├── design.md       # アーキテクチャ・データモデル・ワイヤーフレーム
└── tasks.md        # 実装タスクリスト（12段階）
```

### GitHub Copilot Agent Mode
GitHub Copilotのカスタムプロンプトを使用した効率的な開発：

```
.github/
├── copilot-instructions.md     # 開発ガイドライン
└── prompts/
    ├── setup-project.prompt.md        # プロジェクト初期設定
    ├── implement-task.prompt.md       # タスク実装
    ├── review-task.prompt.md          # 実装レビュー
    └── debug-task.prompt.md           # デバッグ支援
```

## 🚀 開発の流れ

### 1. 環境準備
- Xcode 15.0+
- iOS 16.0+ Deployment Target
- GitHub Copilot Chat拡張機能

### 2. プロジェクト初期設定
```bash
# GitHub Copilot Chatで実行
/setup-project
```

### 3. 段階的実装（12タスク）
```bash
# 次のタスクを実装
/implement-task

# 実装内容をレビュー
/review-task

# 問題があればデバッグ
/debug-task
```

### 4. 実装順序
1. **基盤構築** (Task 1-4)
   - プロジェクト設定
   - データモデル（Card, Settings, ReviewLog）
   - JSONストレージシステム
   - 日付・スケジューラ処理

2. **UI実装** (Task 5-8)
   - HomeView（復習枚数・連続日数表示）
   - StudyView（問題→回答→正誤判定）
   - CardsView（カード一覧・追加・編集）
   - SettingsView（通知時刻設定）

3. **システム統合** (Task 9-11)
   - 通知システム（朝のリマインダー）
   - アプリ統合とナビゲーション
   - E2Eテストと実機確認

## 📋 タスク進捗

実装状況は `.kiro/specs/spaced-repetition-ios-app/tasks.md` で確認できます。

- [ ] 1. プロジェクト初期設定とフォルダ構成
- [ ] 2. 基本データモデルの実装
- [ ] 3. JSONストレージシステムの実装
- [ ] 4. 日付・タイムゾーン処理の実装
- [ ] 5. HomeView画面の実装
- [ ] 6. StudyView画面の実装
- [ ] 7. CardsView画面の実装
- [ ] 8. SettingsView画面の実装
- [ ] 9. 通知システムの実装
- [ ] 10. アプリ統合とナビゲーション
- [ ] 11. 統合テストとデバッグ

## 🎯 成功基準

### 受け入れテスト
- [ ] カード追加 → Study → 正誤判定 → 次回復習日更新
- [ ] 朝の通知が設定時刻に表示される
- [ ] 不正解時にstepIndex=0、次回復習日=明日に設定
- [ ] 通知許可なしでもクラッシュせずに動作
- [ ] データがアプリ再起動後も保持される

### パフォーマンス目標
- アプリ起動 < 2秒
- スムーズなUIアニメーション
- 1000枚以上のカードでも快適動作

## 🏛️ アーキテクチャ

### レイヤー構成
```
Views Layer (SwiftUI + ViewModels)
├─ Domain Layer (Scheduler, NotificationPlanner)
├─ Models Layer (Card, Settings, ReviewLog)
└─ Store Layer (JSON File I/O)
```

### 技術スタック
- **UI**: SwiftUI + MVVM
- **データ保存**: JSON + FileManager
- **通知**: UNUserNotificationCenter
- **テスト**: XCTest
- **日付処理**: Asia/Tokyo TimeZone

## 📱 画面構成

### Home画面
```
今日の復習: 12枚
🔥 連続日数: 5日
[学習を始める]
次回通知: 明日8:00
```

### Study画面
```
3 / 12
問題: 「関ヶ原の戦いは何年？」
[答えを入力する欄]
[🤔 分からない] [❌ 不正解] [✅ 正解]
```

### Cards画面
```
Q: りんごは英語で？
A: apple
[+] 新規カード追加
```

### Settings画面
```
通知時刻: [08:00]
間隔テーブル: 0,1,2,4,7,15,30日
```

## � データ管理機能

### ファイルアプリからのアクセス
Memoraアプリのデータは「ファイル」アプリからアクセス・管理できます：

**保存場所**: `このiPhone内/memora/data/`
- `cards.json` - 学習カードデータ
- `settings.json` - アプリ設定
- `reviewLogs.json` - 学習ログ

### データのバックアップ・共有
1. ファイルアプリで「data」フォルダを開く
2. JSONファイルを選択して「共有」
3. メール、AirDrop、クラウドストレージに保存

詳細は [`docs/FILE_ACCESS_SETUP.md`](docs/FILE_ACCESS_SETUP.md) を参照してください。

## �🔧 開発ツール

### GitHub Copilot使用方法
1. VS CodeでGitHub Copilot Chat拡張機能を有効化
2. プロジェクトルートで以下コマンドを実行：
   - `@workspace /setup-project` - 初期設定
   - `@workspace /implement-task` - タスク実装
   - `@workspace /review-task` - レビュー
   - `@workspace /debug-task` - デバッグ

### 開発ガイドライン
詳細な開発ルールは `.github/copilot-instructions.md` を参照してください。

## 📚 参考資料

- [Kiro Spec Documentation](.kiro/specs/spaced-repetition-ios-app/)
- [GitHub Copilot Custom Prompts](.github/prompts/)
- [SwiftUI Best Practices](https://developer.apple.com/documentation/swiftui)
- [間隔反復学習について](https://ja.wikipedia.org/wiki/間隔反復)

## 🤝 コントリビューション

1. GitHub Copilot Chatで `@workspace /implement-task` を実行
2. 実装完了後 `@workspace /review-task` でレビュー
3. 問題があれば `@workspace /debug-task` でデバッグ
4. テストが通ることを確認してコミット

---

**開発開始**: `@workspace /setup-project` から始めてください！