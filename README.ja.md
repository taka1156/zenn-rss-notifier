# zenn-feed-discord-notifier

English version: [README.md](README.md)

## プロジェクト概要

zenn-feed-discord-notifier は、Zenn の RSS フィードから記事を取得し、新着記事だけを Discord Webhook に通知する小さな MoonBit 製 CLI ツールです。

実行時にはローカルの state.json を参照し、過去に通知した記事を再投稿しないように管理します。標準では Zenn 全体のフィードを対象にしつつ、tags.json にタグを並べることでトピック別フィードをまとめて監視することもできます。

## このプロジェクトでできること

- Zenn の標準フィード、またはトピック別フィードから記事を取得する
- すでに通知済みの記事を除外する
- 新着記事だけを古い順に Discord へ投稿する
- 通知済み GUID を state.json に保存して重複通知を防ぐ
- tags.json に定義した複数タグの最新記事を集約する

## 実行時に使う入力

- DISCORD_WEBHOOK_URL: 必須。通知先の Discord Incoming Webhook URL
- ZENN_FEED_URL: 任意。既定値 https://zenn.dev/feed を上書きする RSS URL
- tags.json: 任意。Zenn のトピックタグを並べた JSON 配列。存在する場合は各タグのフィードを取得して結果を統合する

## 実装の要点

エントリポイントは src/cmd/main にあり、MoonBit の native ターゲット向けに構成されています。HTTP で RSS XML を取得し、記事の title・link・guid を取り出して state.json と比較し、未通知の記事だけを Discord に投稿する構成です。