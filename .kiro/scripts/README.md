# Parent Task Auto-Checker

## 概要
サブタスクが全て完了した際に親タスクを自動でチェックするスクリプト

## 使用方法

### 手動実行
```bash
python3 .kiro/scripts/check-parent-tasks.py .kiro/specs/spaced-repetition-ios-app/tasks.md
```

### 自動実行（Git Pre-commit Hook）
tasks.mdをコミットする際に自動実行されます

## 機能
- tasks.mdを解析して親タスクとサブタスクの関係を把握
- 全サブタスクが完了している親タスクを自動でチェック
- Pre-commit hookでコミット時に自動実行

## 恒久対策として
今後サブタスクを全て完了しても親タスクをチェックし忘れることを防ぎます。

## テスト済み
- Task 3のように既にチェック済みの場合は何もしない
- 新しくサブタスクが完了した場合のみ親タスクをチェック