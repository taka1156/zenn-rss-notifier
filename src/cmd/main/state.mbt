///| 既に通知済みの記事guid一覧
pub struct State {
  known_guids : Array[String]
} derive(ToJson, FromJson)

///| 空のState
fn empty_state() -> State {
  { known_guids: [] }
}

///| state.jsonを読み込む。ファイルが無い/壊れている場合は空のStateを返す(初回実行に相当)
pub async fn load_state(path : String) -> State {
  try {
    let text = @fs.read_file(path).text()
    let json = @json.parse(text)
    @json.from_json(json)
  } catch {
    _ => empty_state()
  }
}

///| state.jsonへ書き込む
pub async fn save_state(path : String, state : State) -> Unit {
  @fs.write_file(
    path,
    state.to_json().stringify(indent=2),
    create_mode=CreateOrTruncate,
  )
}

///| guidが既知一覧に含まれているか
pub fn is_known(known_guids : Array[String], guid : String) -> Bool {
  for g in known_guids {
    if g == guid {
      return true
    }
  }
  false
}
