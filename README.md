# Zed の設定

Zed のユーザー設定フォルダ（Windows は `%APPDATA%\Zed`、macOS は `~/.config/zed`）をこのリポジトリの作業フォルダとして使います。`keymap.json`、`tasks.json`、`AGENTS.md` は Git で直接管理します。

`settings.shared.json` には共有する設定を保存します。Zed が使う `settings.json` は Git の対象外です。各端末の `ssh_connections` はその端末の `settings.json` に保存されます。

## 設定を同期する

リポジトリのルートから実行します。Windows は PowerShell 7.3 以降、macOS は標準搭載の Perl を使います。

| 目的 | Windows | macOS |
| --- | --- | --- |
| Zed の変更を共有版に書き出す | `pwsh -File ./sync-settings.ps1 Export` | `/usr/bin/perl ./sync-settings.pl Export` |
| 共有版を Zed に反映する | `pwsh -File ./sync-settings.ps1 Apply` | `/usr/bin/perl ./sync-settings.pl Apply` |

`Export` の後は差分を確認してコミットします。SSH 接続先は除かれます。`Apply` はその端末の SSH 接続先を引き継ぎ、それ以外の設定を共有版で更新します。

新しい端末では、Zed の設定フォルダにこのリポジトリをチェックアウトしてから `Apply` を実行します。既存の設定がある場合は、同名ファイルを取り込む前に差分を確認してください。
