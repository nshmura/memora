# セットアップガイド

## 1. Bundle Identifierの変更

プロジェクトを自分用にセットアップするには：

1. **Xcodeでプロジェクトを開く**
2. **Target「memora」を選択**
3. **「Signing & Capabilities」タブ**
4. **Bundle Identifier**を変更：
   - 現在：`com.nshmura.memora`
   - 推奨：`com.yourname.memora` または `com.example.memora`

## 2. Development Team設定

1. **「Signing & Capabilities」タブ**
2. **Team**を自分のApple Developer アカウントに設定
3. **「Automatically manage signing」**にチェック

## 3. ビルド・実行

```bash
cd memora
xcodebuild clean build -target memora
```

または Xcodeで **⌘+R** で実行

## 4. ファイルアプリでのデータ確認

1. アプリでカードを作成
2. 「ファイル」アプリ → 「このiPhone内」→ 「memora」→ 「data」
3. JSONファイルが表示されます

## トラブルシューティング

- **「Team is required」エラー**: Apple Developer アカウントでサインインが必要
- **Bundle ID重複エラー**: Bundle Identifierを一意の値に変更
- **ファイルアプリに表示されない**: Info.plistで`UIFileSharingEnabled`が有効か確認