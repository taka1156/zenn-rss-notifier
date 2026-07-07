///|
/// デフォルトのフィードURL(環境変数 ZENN_FEED_URL で上書き可能)
let default_feed_url : String = "https://zenn.dev/feed"

///|
let state_path : String = "state.json"

///|
let tags_path : String = "tags.json"

///|
async fn main {
  let env = @sys.get_env_vars()
  let feed_url = match env.get("ZENN_FEED_URL") {
    Some(v) if v != "" => v
    _ => default_feed_url
  }

  guard env.get("DISCORD_WEBHOOK_URL") is Some(webhook_url) else {
    println(
      "[error] 環境変数 DISCORD_WEBHOOK_URL が設定されていません",
    )
    return
  }
  
  let state = load_state(state_path)

  let items = match load_tags(tags_path) {
    Some(tags) if tags.length() > 0 => fetch_by_tags(tags)
    _ => {
      println("フィードを取得します: \{feed_url}")
      fetch_feed(feed_url)
    }
  }

  println("取得件数: \{items.length()}")

  let new_items = items.filter(fn(item) {
    !is_known(state.known_guids, item.guid)
  })

  if new_items.length() == 0 {
    println("新着記事はありませんでした")
    return
  }

  // 古い記事から順に投稿する
  let ordered = new_items.rev()
  for item in ordered {
    notify_discord(webhook_url, item)
  }
  let all_guids = items.map(fn(item) { item.guid })
  save_state(state_path, { known_guids: all_guids })
  println(
    "\{new_items.length()}件の新着記事をDiscordに投稿しました",
  )
}
