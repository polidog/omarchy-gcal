# Google Calendar — Omarchy バーウィジェット

次の Google カレンダーの予定を Omarchy のバーに出します。クリックすると今後の予定を一覧で表示します。

[English](README.md)

- バーには、まだ終わっていない時刻付きの予定のうち次のものを出します。`13:00 定例`、進行中なら `now 定例`、翌日以降なら `9/26 08:30 …`
- パネルには今後の予定を日ごとに並べます（終日の予定も含む）。進行中の予定は強調表示します
- 予定をクリックすると、Google Meet のリンクがあれば Meet を、なければ Google カレンダーの予定を開きます
- `gcal` に登録したすべてのアカウントの予定をまとめて表示します

## 必要なもの

[gcal](https://github.com/polidog/gcal) 0.2.0 以降にログイン済みであること（`gcal init`、`gcal login`）。
`PATH` と `~/.cargo/bin`、`~/.local/bin` から探します。

## インストール

```bash
omarchy plugin add https://github.com/polidog/omarchy-gcal.git --enable
```

`--enable` でバーに追加されます。更新と削除:

```bash
omarchy plugin update io.github.polidog.gcal   # 更新
omarchy plugin remove io.github.polidog.gcal   # 削除
```

プラグインは `omarchy-shell` の中でサンドボックスなしに動くので、先にコードを読んでください。QML と JS が 1 つずつです。

## 設定

| キー | 既定値 | 内容 |
|-----|---------|--------------|
| `days` | `7` | パネルに何日先まで出すか |
| `refreshMinutes` | `5` | `gcal list` を実行する間隔（分） |

## 操作

左クリックでパネルを開く · 右クリックで再読み込み · `r` 再読み込み · `Esc` 閉じる

## 開発

```bash
TZ=Asia/Tokyo node test.js
```

MIT
