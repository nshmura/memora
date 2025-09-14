# Implementation Plan

- [x] 1. プロジェクト初期設定とフォルダ構成
  - Xcodeプロジェクト作成（SpacedStudy、iOS 16.0+、SwiftUI）
  - フォルダ構成作成：App/Views/Domain/Models/Store/Tests
  - Info.plistに通知権限設定追加
  - _Requirements: 7.3_

- [x] 2. 基本データモデルの実装
  - [x] 2.1 Cardモデルの作成とテスト
    - Card構造体をCodable準拠で実装
    - CardのUnit Testを作成（初期化、JSON変換テスト）
    - _Requirements: 1.1, 4.2_

  - [x] 2.2 Settingsモデルの作成とテスト
    - Settings構造体をデフォルト値付きで実装
    - SettingsのUnit Testを作成
    - _Requirements: 2.4, 5.2_

  - [x] 2.3 ReviewLogモデルの作成とテスト
    - ReviewLog構造体を実装
    - ReviewLogのUnit Testを作成
    - _Requirements: 4.2_

- [x] 3. JSONストレージシステムの実装
  - [x] 3.1 基本Storeクラスの作成
    - ObservableObjectとしてStoreクラス実装
    - DocumentsディレクトリへのJSONファイル読み書き機能
    - _Requirements: 4.1, 4.2_

  - [x] 3.2 Storeのエラーハンドリングとテスト
    - ファイル読み書きエラーの適切な処理
    - StoreのUnit Test作成（保存・読み込み・エラーケース）
    - _Requirements: 4.3_

- [x] 4. 日付・タイムゾーン処理の実装
  - [x] 4.1 JST日付ユーティリティの作成
    - Asia/Tokyoタイムゾーンでの日付開始時刻計算
    - 日付境界処理のUnit Test作成
    - _Requirements: 5.1, 5.2_

  - [x] 4.2 Schedulerクラスの実装
    - gradeCard、calculateNextDue、startOfDayメソッド実装
    - 間隔テーブル[0,1,2,4,7,15,30]を使用した次回復習日計算
    - _Requirements: 1.3, 1.4, 5.1_

  - [x] 4.3 Schedulerの包括的テスト
    - 正解時stepIndex増加テスト
    - 不正解時stepIndex=0、明日設定テスト
    - 23:59 JST境界テスト
    - _Requirements: 5.3, 7.1_

- [x] 5. HomeView画面の実装
  - [x] 5.1 HomeViewModelの作成
    - 今日の復習枚数計算ロジック
    - 連続学習日数計算ロジック
    - 次回通知予定表示ロジック
    - _Requirements: 2.1_

  - [x] 5.2 HomeViewのUI実装
    - SwiftUIでHome画面レイアウト作成
    - 学習開始ボタンとナビゲーション
    - 基本的なレイアウトとスタイリング
    - _Requirements: 2.1, 6.1, 6.2_

- [x] 6. StudyView画面の実装
  - [x] 6.1 StudyViewModelの作成
    - 今日復習すべきカード取得ロジック
    - 正誤判定とScheduler連携ロジック
    - 学習進捗管理
    - _Requirements: 1.2, 1.3, 1.4_

  - [x] 6.2 StudyViewのUI実装
    - 問題表示→回答表示→正誤ボタンのフロー
    - 進捗表示とカード切り替えアニメーション
    - 学習完了時の通知権限要求
    - _Requirements: 2.2, 3.1_

- [x] 7. CardsView画面の実装
  - [x] 7.1 CardsViewModelの作成
    - カード一覧表示ロジック
    - カード追加・編集・削除ロジック
    - 検索・フィルタ機能
    - _Requirements: 2.3_

  - [x] 7.2 CardsViewのUI実装
    - カード一覧表示とリスト操作
    - カード追加・編集フォーム
    - 基本的なUI操作性
    - _Requirements: 2.3, 6.1, 6.2_

- [x] 8. SettingsView画面の実装
  - [x] 8.1 SettingsViewModelの作成
    - 通知時刻設定の管理
    - 設定変更時の通知再編成
    - _Requirements: 2.4_

  - [x] 8.2 SettingsViewのUI実装
    - 通知時刻のPicker
    - 間隔テーブル表示（編集不可）
    - 設定変更の即座反映
    - _Requirements: 2.4_

- [ ] 9. 通知システムの実装
  - [ ] 9.1 NotificationPlannerクラスの基本実装
    - UNUserNotificationCenter権限要求機能
    - 基本的な通知予約・削除機能
    - _Requirements: 3.1, 3.2_

  - [ ] 9.2 朝の通知実装
    - scheduleMorningReminder（毎朝の復習通知）
    - 通知予約の管理とreorganizeNotificationsメソッド
    - NotificationPlannerのUnit Test作成
    - _Requirements: 3.2, 3.3_

- [ ] 10. アプリ統合とナビゲーション
  - [ ] 10.1 メインアプリ構造の実装
    - SpacedStudyApp.swiftでアプリエントリーポイント作成
    - TabViewでの4画面ナビゲーション実装
    - Store依存性注入の設定
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [ ] 10.2 アプリライフサイクル処理
    - アプリ起動時のデータ読み込み
    - バックグラウンド復帰時の通知再編成
    - アプリ終了時のデータ保存
    - _Requirements: 4.1, 3.4_

- [ ] 11. 統合テストとデバッグ
  - [ ] 11.1 E2Eシナリオテストの作成
    - 新規ユーザーフロー（カード追加→学習→通知設定）
    - 日次学習フロー（通知→起動→復習→次回予約）
    - エラー回復フロー（権限拒否→代替案内→再許可）
    - _Requirements: 7.1, 7.2_

  - [ ] 11.2 実機テストと最終調整
    - 実機での通知動作確認
    - 権限未許可時の動作確認
    - パフォーマンステスト（大量カード処理）
    - _Requirements: 7.2_