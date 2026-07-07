.PHONY: setup build check fmt test run clean reset-state

# MoonBitのビルドターゲット(このプロジェクトはネイティブ実行のみ想定)
TARGET := native

## 依存パッケージを解決してインストールする
setup:
	moon update
	moon check --target $(TARGET)

## 型チェック(警告もエラー扱い)
check:
	moon check --target $(TARGET)

## フォーマット
fmt:
	moon fmt

## ビルド
build: check
	moon build --target $(TARGET)

## ユニットテストがあれば実行(現状テストファイルはまだ無し)
test:
	moon test --target $(TARGET)

## 通知処理をローカル実行する
# 例: make run DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/xxx/yyy
#     make run DISCORD_WEBHOOK_URL=... ZENN_FEED_URL=https://zenn.dev/your_name/feed
run: build
	@if [ -z "$(DISCORD_WEBHOOK_URL)" ]; then \
		echo "エラー: DISCORD_WEBHOOK_URL を指定してください (例: make run DISCORD_WEBHOOK_URL=...)"; \
		exit 1; \
	fi
	DISCORD_WEBHOOK_URL="$(DISCORD_WEBHOOK_URL)" \
	ZENN_FEED_URL="$(ZENN_FEED_URL)" \
	moon run src/cmd/main --target $(TARGET)

## ビルド成果物の削除
clean:
	moon clean

## state.json を空に戻す(次回実行時に全件が新着扱いになるので注意)
reset-state:
	echo '{"known_guids": []}' > state.json
