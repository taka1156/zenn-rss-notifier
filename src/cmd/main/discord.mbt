/// Discord　Webhook に送るペイロード
pub struct DiscordPayload {
  content : String
} derive(ToJson)


/// 1記事分をDiscordのWebhookに投稿する
pub async fn notify_discord(webhook_url: String, item: Item) -> Unit {
  let content = "**\{item.title}**\n\{item.link}"
  let payload: DiscordPayload = { content,  } 
  let (response, _body) = @http.post(
    webhook_url,
    payload.to_json().stringify(),
    headers={"Content-Type": "application/json"},
  )

  guard response.code is (200..=299) else {
    println("[warn] Discord への投稿に失敗しました。: \{response.code} \{response.reason}")
  }
}
