# Zed の設定

Zed のユーザー設定フォルダ（Windows では `%APPDATA%\Zed`）をこのリポジトリの作業フォルダとして使います。`keymap.json`、`tasks.json`、`AGENTS.md` は Git で直接管理します。

`settings.shared.json` には共有する設定を保存します。Zed が使う `settings.json` は Git の対象外です。各端末の `ssh_connections` はその端末の `settings.json` に保存されます。

## 設定を同期する

PowerShell 7.3 以降で、リポジトリのルートから実行します。

- Zed で設定を変えたら `pwsh -File ./sync-settings.ps1 Export` を実行し、差分を確認してコミットします。SSH 接続先は除かれます。
- Git から更新を取得したら `pwsh -File ./sync-settings.ps1 Apply` を実行します。端末の SSH 接続先を引き継ぎ、それ以外の設定を共有版で更新します。

新しい端末では、Zed の設定フォルダにこのリポジトリをチェックアウトしてから `Apply` を実行します。既存の設定がある場合は、同名ファイルを取り込む前に差分を確認してください。
