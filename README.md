# zenn-feed-discord-notifier

Japanese version: [README.ja.md](README.ja.md)

## Overview

zenn-feed-discord-notifier is a small MoonBit CLI that fetches articles from Zenn RSS feeds and posts newly published entries to a Discord webhook.

The notifier keeps a local state file so it can skip articles that were already sent in previous runs. By default it reads the main Zenn feed, and it can also aggregate topic-specific feeds when tags are listed in tags.json.

## What This Project Does

- Fetches articles from the default Zenn feed or from topic feeds.
- Filters out entries that have already been notified.
- Posts only new articles to Discord in chronological order.
- Stores known article GUIDs in state.json to avoid duplicate notifications.
- Optionally merges recent entries from multiple tags defined in tags.json.

## Runtime Inputs

- DISCORD_WEBHOOK_URL: required Discord Incoming Webhook URL.
- ZENN_FEED_URL: optional RSS URL that overrides the default https://zenn.dev/feed.
- tags.json: optional JSON array of Zenn topic tags. When present, the notifier fetches each topic feed and merges the latest entries.

## Implementation Summary

The application entry point lives under src/cmd/main and is designed for the native MoonBit target. It fetches RSS XML over HTTP, parses item blocks, compares item GUIDs against the saved state, and sends each unseen article to Discord as a simple message containing the title and link.