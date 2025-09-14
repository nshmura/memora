# Requirements Document

## Introduction

忘却曲線に基づく毎日の学習アプリをiOSネイティブで実装するMVPです。中学生でも理解できるシンプルな設計で、GitHub Copilotを活用して段階的に実装できる構成を目指します。SwiftUIを使用し、ローカル通知とローカルデータ保存に焦点を当てたミニマムな機能セットを提供します。

## Requirements

### Requirement 1

**User Story:** As a 学習者, I want カードベースの学習システムを使って復習できるように, so that 忘却曲線に基づいて効率的に記憶を定着させることができる

#### Acceptance Criteria

1. WHEN ユーザーがカードを追加する THEN システム SHALL カードをローカルストレージに保存する
2. WHEN ユーザーが学習を開始する THEN システム SHALL 今日復習すべきカードを表示する
3. WHEN ユーザーがカードに正解する THEN システム SHALL 次回復習日を間隔テーブル[0,1,2,4,7,15,30]日に基づいて更新する
4. WHEN ユーザーがカードに不正解する THEN システム SHALL stepIndexを0にリセットし、次回復習日を明日に設定する

### Requirement 2

**User Story:** As a 学習者, I want 3つの主要画面（Home/Cards/Settings）でアプリを操作できるように, so that 直感的にアプリを使用できる

#### Acceptance Criteria

1. WHEN ユーザーがHomeを開く THEN システム SHALL 今日の復習枚数と連続学習日数を表示する
2. WHEN ユーザーがCardsを開く THEN システム SHALL カード一覧と追加・編集機能を提供する
3. WHEN ユーザーがSettingsを開く THEN システム SHALL 通知時刻設定を提供する

### Requirement 3

**User Story:** As a 学習者, I want ローカル通知で復習を思い出せるように, so that 学習習慣を継続できる

#### Acceptance Criteria

1. WHEN ユーザーが初回学習完了後 THEN システム SHALL 通知許可を求める
2. WHEN 通知が許可されている THEN システム SHALL 毎朝設定時刻に「今日の復習 X枚」通知を送信する
3. WHEN 通知予約が多数ある THEN システム SHALL 既存予約を適切に管理する

### Requirement 4

**User Story:** As a 学習者, I want データがローカルに安全に保存されるように, so that アプリを再起動してもデータが失われない

#### Acceptance Criteria

1. WHEN アプリが起動する THEN システム SHALL DocumentsディレクトリからJSONファイルを読み込む
2. WHEN データが変更される THEN システム SHALL 変更をJSONファイルに即座に保存する
3. WHEN JSONファイルが存在しない THEN システム SHALL デフォルト設定で初期化する
4. IF 将来Core Dataに移行する THEN システム SHALL Storeレイヤーの差し替えで対応できる

### Requirement 5

**User Story:** As a 学習者, I want 日本時間（JST）で日付境界が正しく処理されるように, so that 海外にいても正確な復習スケジュールが維持される

#### Acceptance Criteria

1. WHEN 23:59 JSTで学習する THEN システム SHALL 翌日00:00 JSTを正しく次の日として計算する
2. WHEN 復習日を計算する THEN システム SHALL Asia/Tokyoタイムゾーンで日付の開始時刻を使用する


### Requirement 6

**User Story:** As a 初学者, I want アクセシビリティとローカライズに対応したアプリを使えるように, so that 様々な環境で快適に学習できる

#### Acceptance Criteria

1. WHEN ユーザーがDynamic Typeを変更する THEN システム SHALL フォントサイズを適切に調整する
2. WHEN VoiceOverが有効 THEN システム SHALL 適切な音声読み上げラベルを提供する
3. WHEN 言語設定が日本語/英語 THEN システム SHALL 対応する言語でUIを表示する

### Requirement 7

**User Story:** As a 開発者, I want 段階的に実装・テストできる構成になっているように, so that GitHub Copilotを活用して確実に機能を構築できる

#### Acceptance Criteria

1. WHEN 単体テストを実行する THEN システム SHALL 日付境界、正誤遷移、通知予約の主要ケースをテストする
2. WHEN 実機でテストする THEN システム SHALL 通知許可なしでもクラッシュせずに動作する
3. WHEN モジュール構成を確認する THEN システム SHALL Views/Domain/Models/Store/Testsの明確な分離を持つ
4. IF 将来機能を拡張する THEN システム SHALL CloudKit、FSRS、Widgetなどに対応できる設計余白を持つ