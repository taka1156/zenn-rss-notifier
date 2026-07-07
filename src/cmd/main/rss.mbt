/// RSSフィードの1期自分の情報
pub struct Item {
  title : String
  link : String
  guid : String
} derive(Debug)

/// haystackの from 番目以降から、needle を探し、見つかった開始位置を探す
fn index_of(haystack : String, needle : String, from : Int) -> Int? {
  let hlen = haystack.length()
  let nlen = needle.length()

  if nlen == 0 {
    return Some(from)
  }

  if from < 0 || from + nlen > hlen {
    return None
  }

  for i = from; i + nlen <= hlen; i = i + 1 {
    if matches_at(haystack, needle, i, nlen) {
      return Some(i)
    }
  }

  None
}

fn matches_at(haystack : String, needle : String, pos : Int, nlen : Int) -> Bool {
  for i = 0; i < nlen; i = i + 1 {
    if haystack[pos + i] != needle[i] {
      return false
    }
  }
  true
}

/// `<![CDATA[ ... ]]>` で囲まれていた場合、中身だけを取り出す
fn strip_cdata(s : String) -> String {
  let prefix = "<![CDATA["
  let suffix = "]]>"
  let plen = prefix.length()
  let slen = suffix.length()
  if s.length() >= plen + slen &&
    s[:plen].to_owned() == prefix &&
    s[s.length() - slen:].to_owned() == suffix {
    s[plen:s.length() - slen].to_owned()
  } else {
    s
  }
}

/// XML断片 `xml` の中から `<tag>...</tag>` の中身を取り出す(CDATAは自動で剥がす)
fn extract_tag(xml : String, tag : String) -> String? {
  let open_needle = "<\{tag}"
  guard index_of(xml, open_needle, 0) is Some(start_tag) else { return None }
  guard index_of(xml, ">", start_tag) is Some(gt) else { return None }
  let content_start = gt + 1
  let close_needle = "</\{tag}>"
  guard index_of(xml, close_needle, content_start) is Some(end_tag) else {
    return None
  }
  let raw = xml[content_start:end_tag].to_owned()
  Some(strip_cdata(raw))
}

/// RSS本文から `<item>...</item>` のブロックだけを全部切り出す
fn extract_item_blocks(xml : String) -> Array[String] {
  let items : Array[String] = []
  let close_tag = "</item>"
  fn go(pos : Int) -> Unit {
    match index_of(xml, "<item>", pos) {
      None => ()
      Some(start) =>
        match index_of(xml, close_tag, start) {
          None => ()
          Some(end_idx) => {
            let end = end_idx + close_tag.length()
            items.push(xml[start:end].to_owned())
            go(end)
          }
        }
    }
  }

  go(0)
  items
}

/// RSSのXML文字列から記事一覧を取り出す
pub fn parse_feed(xml : String) -> Array[Item] {
  let result : Array[Item] = []
  for block in extract_item_blocks(xml) {
    match (extract_tag(block, "title"), extract_tag(block, "link")) {
      (Some(title), Some(link)) => {
        let guid = match extract_tag(block, "guid") {
          Some(g) => g
          None => link
        }
        result.push({ title, link, guid })
      }
      _ => ()
    }
  }
  result
}

/// 指定したURLのRSSフィードを取得してパースする
pub async fn fetch_feed(feed_url : String) -> Array[Item] {
  let (response, body) = @http.get(feed_url)
  guard response.code is (200..=299) else {
    fail(
      "フィード取得に失敗しました: \{response.code} \{response.reason} (\{feed_url})",
    )
  }
  parse_feed(body.text())
}

/// タグ指定に基づいて、複数のフィードを取得してマージする
pub async fn fetch_by_tags(tags : Array[String]) -> Array[Item] {
  let merged_item : Array[Item] = []
  let merged_guid : Array[String] = []

  for tag in tags {
    let feed_url = "https://zenn.dev/topics/\{tag}/feed"
    println("フィードを取得します: \{feed_url}")

    let all_items = fetch_feed(feed_url)
    let items = take(all_items, 5)

    for item in items {
      let already_merged = is_known(merged_guid, item.guid)
      if !already_merged {
        merged_item.push(item)
        merged_guid.push(item.guid)
      }
    }
  }

  merged_item
}

/// 指定した件数だけ先頭から取り出す
fn take(items : Array[Item], n : Int) -> Array[Item] {
  let result : Array[Item] = []
  for i = 0; i < n && i < items.length(); i = i + 1 {
    result.push(items[i])
  }
  result
}

/// 複数タグがある場合の処理
pub async fn resolve_items(
  feed_url : String,
  tags_path : String,
) -> Array[Item] {
  let tags_result = load_tags(tags_path)
  match tags_result {
    Some(tags) if tags.length() > 0 => fetch_by_tags(tags)
    _ => fetch_feed(feed_url)
  }
}

/// タグ指定の解決
pub async fn load_tags(path : String) -> Array[String]? {
  try {
    let text = @fs.read_file(path).text()
    let json = @json.parse(text)
    let tags: Array[String] = @json.from_json(json)
    Some(tags)
  } catch {
    err => {
      println("[warn] \{path} の読み込みに失敗しました: \{err}")
      None
    }
  }
}
