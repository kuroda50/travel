const Map<String, List<String>> destinationsByArea = {
  "ヨーロッパ": [
    "アイスランド",
    "アイルランド",
    "アゼルバイジャン",
    "アルバニア",
    "アルメニア",
    "アンドラ",
    "イギリス",
    "イタリア",
    "ウクライナ",
    "エストニア",
    "オーストリア",
    "オランダ",
    "ギリシャ",
    "クロアチア",
    "コソボ",
    "サンマリノ",
    "ジョージア",
    "スイス",
    "スウェーデン",
    "スペイン",
    "スロバキア",
    "スロベニア",
    "セルビア",
    "タジキスタン",
    "チェコ",
    "デンマーク",
    "ドイツ",
    "ノルウェー",
    "ハンガリー",
    "フィンランド",
    "フランス",
    "ブルガリア",
    "ベラルーシ",
    "ベルギー",
    "ボスニア・ヘルツェゴビナ",
    "ポルトガル",
    "ポーランド",
    "マケドニア",
    "マルタ",
    "モナコ",
    "モルドバ",
    "モンテネグロ",
    "ラトビア",
    "リトアニア",
    "リヒテンシュタイン",
    "ルクセンブルク",
    "ルーマニア",
    "ロシア"
  ],
  "北中米": [
    "アメリカ",
    "カナダ",
    "メキシコ",
    "バハマ",
    "バルバドス",
    "キューバ",
    "ドミニカ共和国",
    "ハイチ",
    "ジャマイカ",
    "セントクリストファー・ネイビス",
    "セントルシア",
    "セントビンセント・グレナディーン",
    "トリニダード・トバゴ",
    "アンティグア・バーブーダ",
    "ベリーズ",
    "コスタリカ",
    "エルサルバドル",
    "グアテマラ",
    "ホンジュラス",
    "ニカラグア",
    "パナマ"
  ],
  "南米": [
    "アルゼンチン",
    "ボリビア",
    "ブラジル",
    "チリ",
    "コロンビア",
    "エクアドル",
    "ガイアナ",
    "パラグアイ",
    "ペルー",
    "スリナム",
    "ウルグアイ",
    "ベネズエラ"
  ],
  "オセアニア・ハワイ": [
    "オーストラリア",
    "ニュージーランド",
    "フィジー",
    "パプアニューギニア",
    "サモア",
    "ソロモン諸島",
    "トンガ",
    "バヌアツ",
    "ハワイ"
  ],
  "アジア": [
    "アフガニスタン",
    "バングラデシュ",
    "ブータン",
    "ブルネイ",
    "カンボジア",
    "中国",
    "台湾",
    "インド",
    "インドネシア",
    "イラン",
    "イラク",
    "イスラエル",
    "ヨルダン",
    "カザフスタン",
    "韓国",
    "クウェート",
    "キルギス",
    "ラオス",
    "レバノン",
    "マレーシア",
    "モルディブ",
    "モンゴル",
    "ミャンマー",
    "ネパール",
    "オマーン",
    "パキスタン",
    "フィリピン",
    "カタール",
    "サウジアラビア",
    "シンガポール",
    "スリランカ",
    "シリア",
    "タジキスタン",
    "タイ",
    "トルクメニスタン",
    "アラブ首長国連邦",
    "ウズベキスタン",
    "ベトナム",
    "イエメン"
  ],
  "日本": [
    "北海道",
    "青森県",
    "岩手県",
    "宮城県",
    "秋田県",
    "山形県",
    "福島県",
    "茨城県",
    "栃木県",
    "群馬県",
    "埼玉県",
    "千葉県",
    "東京都",
    "神奈川県",
    "新潟県",
    "富山県",
    "石川県",
    "福井県",
    "山梨県",
    "長野県",
    "岐阜県",
    "静岡県",
    "愛知県",
    "三重県",
    "滋賀県",
    "京都府",
    "大阪府",
    "兵庫県",
    "奈良県",
    "和歌山県",
    "鳥取県",
    "島根県",
    "岡山県",
    "広島県",
    "山口県",
    "徳島県",
    "香川県",
    "愛媛県",
    "高知県",
    "福岡県",
    "佐賀県",
    "長崎県",
    "熊本県",
    "大分県",
    "宮崎県",
    "鹿児島県",
    "沖縄県"
  ],
  "アフリカ・中東": [
    "アルジェリア",
    "アンゴラ",
    "ベナン",
    "ボツワナ",
    "ブルキナファソ",
    "ブルンジ",
    "カメルーン",
    "カーボベルデ",
    "中央アフリカ共和国",
    "チャド",
    "コモロ",
    "コンゴ共和国",
    "コンゴ民主共和国",
    "ジブチ",
    "エジプト",
    "赤道ギニア",
    "エリトリア",
    "エスワティニ",
    "エチオピア",
    "ガボン",
    "ガンビア",
    "ガーナ",
    "ギニア",
    "ギニアビサウ",
    "コートジボワール",
    "ケニア",
    "レソト",
    "リベリア",
    "リビア",
    "マダガスカル",
    "マラウイ",
    "マリ",
    "モーリタニア",
    "モーリシャス",
    "モロッコ",
    "モザンビーク",
    "ナミビア",
    "ニジェール",
    "ナイジェリア",
    "ルワンダ",
    "サントメ・プリンシペ",
    "セネガル",
    "セーシェル",
    "シエラレオネ",
    "ソマリア",
    "南アフリカ",
    "南スーダン",
    "スーダン",
    "タンザニア",
    "トーゴ",
    "チュニジア",
    "ウガンダ",
    "ザンビア",
    "ジンバブエ",
    "アラブ首長国連邦",
    "サウジアラビア",
    "イエメン",
    "オマーン",
    "カタール",
    "バーレーン",
    "クウェート",
    "イスラエル",
    "ヨルダン",
    "レバノン",
    "シリア",
    "イラク",
    "イラン"
  ]
};
