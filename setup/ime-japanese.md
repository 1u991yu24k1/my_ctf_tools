# Ubuntu 26.04でMozcを導入し, Ctrl+SpaceでIMEをON/OFFする手順

## 目的

Ubuntu 26.04のGNOMEデスクトップでUSキーボードを使用し, Windows版Google日本語入力に近い操作体系を構成します.

完成後の主な操作は次のとおりです.

| 操作 | 動作 |
|---|---|
| `Super+Space` | GNOMEの入力ソースを`Japanese (Mozc)`と`English (US)`の間で切り替える |
| `Ctrl+Space` | `Japanese (Mozc)`内でIMEをON/OFFする |
| 未入力時の`Space` | 半角スペースを入力する |
| 文字入力中の`Space` | 変換を開始する |
| 変換中の`Space` | 次の変換候補へ進む |
| 変換中の`Shift+Space` | 前の変換候補へ戻る |
| `Enter` | 入力または候補を確定する |

Mozcの表示は次の意味です.

| 表示 | 状態 |
|---|---|
| `en` | GNOMEの入力ソースが`English (US)` |
| `A` | GNOMEの入力ソースが`Japanese (Mozc)`で, MozcのIMEは無効 |
| `あ` | GNOMEの入力ソースが`Japanese (Mozc)`で, MozcのIMEは有効 |

> [!IMPORTANT]
> Google公式のGoogle日本語入力はLinux版を提供していません. Ubuntuでは, Google日本語入力を起源とするオープンソース版のMozcを使用します.
>
> Mozc設定内の`MS-IME`は入力エンジンをMicrosoft IMEへ変更する設定ではありません. Mozcの変換エンジンを維持したまま, キー操作だけをMS-IME風にするプリセットです.

---

## 1. IBus, Mozc, 日本語関連パッケージをインストールする

端末を開き, 次を実行します.

```bash
sudo apt update
sudo apt install ibus-mozc mozc-utils-gui fonts-noto-cjk
```

UbuntuのGUI表示も日本語化する場合は, 次も導入します.

```bash
sudo apt install language-pack-ja language-pack-gnome-ja
```

日本語入力だけが目的の場合, 言語パックは必須ではありません.

インストール後, 一度ログアウトしてログインし直します.

---

## 2. IBusを使用していることを確認する

次を実行します.

```bash
im-config -m
```

出力に`ibus`が含まれていることを確認します.

IBusが選択されていない場合は, 次を実行します.

```bash
im-config -n ibus
```

その後, ログアウトしてログインし直します.

実行中の入力メソッドを確認します.

```bash
pgrep -a -f 'ibus|fcitx'
```

正常な例です.

```text
/usr/bin/ibus-daemon --panel disable
/usr/lib/ibus-mozc/ibus-engine-mozc --ibus
```

`fcitx5`も同時に動いている場合は競合する可能性があります. 本手順ではIBusのみを使用します.

Waylandセッションであることも確認できます.

```bash
echo "$XDG_SESSION_TYPE"
```

Ubuntu 26.04の標準GNOME環境では, 通常は次のように表示されます.

```text
wayland
```

---

## 3. GNOMEへJapanese (Mozc)を追加する

設定画面を開きます.

```bash
gnome-control-center keyboard
```

GUIで次の順に操作します.

```text
設定
  → キーボード
  → 入力ソース
  → 入力ソースを追加
  → 日本語
  → 日本語 (Mozc)
  → 追加
```

入力ソースには, 最低でも次の2つを登録します.

```text
Japanese (Mozc)
English (US)
```

単なる`日本語`は日本語キーボード配列です. かな漢字変換を使用するには`日本語 (Mozc)`を追加します.

現在の入力ソースは次で確認できます.

```bash
gsettings get org.gnome.desktop.input-sources sources
```

正常な例です.

```text
[('ibus', 'mozc-jp'), ('xkb', 'us')]
```

---

## 4. GNOMEの入力ソース切り替えを確認する

GNOMEの標準ショートカットは次です.

```text
Super+Space
```

`Super`は通常, Windowsロゴの付いたキーです.

GNOME Text Editorを起動します.

```bash
gnome-text-editor
```

Text Editor上で`Super+Space`を押し, 画面上部の入力ソース表示が次の間で切り替わることを確認します.

```text
en
A または あ
```

> [!NOTE]
> `Ctrl+Space`でMozcをONにできるのは, GNOMEの入力ソースが`Japanese (Mozc)`のときだけです.
>
> 右上が`en`の場合は, 先に`Super+Space`で`Japanese (Mozc)`へ切り替えます.

---

## 5. GNOME側のCtrl+Space割り当てを解除する

本手順では, `Ctrl+Space`をMozc内部で使用します. GNOMEの入力ソース切り替えには割り当てません.

現在の設定を確認します.

```bash
gsettings get org.gnome.desktop.wm.keybindings switch-input-source
gsettings get org.gnome.desktop.wm.keybindings switch-input-source-backward
```

推奨値は次です.

```text
['<Super>space']
['<Shift><Super>space']
```

異なる場合は, 次で標準設定へ戻します.

```bash
gsettings set \
  org.gnome.desktop.wm.keybindings \
  switch-input-source \
  "['<Super>space']"

gsettings set \
  org.gnome.desktop.wm.keybindings \
  switch-input-source-backward \
  "['<Shift><Super>space']"
```

---

## 6. Mozcプロパティを開く

Ubuntuの`mozc-utils-gui`では, `mozc_tool`は通常のPATHに含まれない`/usr/lib/mozc`へ配置されます.

次でMozcプロパティを起動します.

```bash
/usr/lib/mozc/mozc_tool --mode=config_dialog
```

ファイルの配置場所を確認する場合は次です.

```bash
dpkg -L mozc-utils-gui | grep '/mozc_tool$'
```

期待される出力です.

```text
/usr/lib/mozc/mozc_tool
```

アプリ一覧から`Mozc の設定`を起動しても構いません.

### 任意, mozc_toolへPATHを通す

毎回フルパスを入力したくない場合は, `~/.bashrc`へ追加します.

```bash
printf '\nexport PATH="$PATH:/usr/lib/mozc"\n' >> ~/.bashrc
source ~/.bashrc
```

以後は次で起動できます.

```bash
mozc_tool --mode=config_dialog
```

システム全体で使用するシンボリックリンクを作る場合は次です.

```bash
sudo ln -s /usr/lib/mozc/mozc_tool /usr/local/bin/mozc_tool
```

既に同名ファイルが存在する場合は, シンボリックリンクを作成しないでください.

---

## 7. キー設定のベースをMS-IMEへ変更する

Mozcプロパティの`一般`タブを開きます.

次のように設定します.

```text
一般
  → キー設定の選択
  → MS-IME
```

`MS-IME`プリセットを使用する目的は, 次の基本操作を最初から確保することです.

| モード | キー | 動作 |
|---|---|---|
| 変換前入力中 | `Space` | 変換を開始 |
| 変換中 | `Space` | 次候補を選択 |
| 変換中 | `Shift+Space` | 前候補を選択 |
| 変換前入力中 | `Enter` | 入力を確定 |
| 変換中 | `Enter` | 候補を確定 |
| 入力文字なし | `Space` | スペースを入力 |

> [!IMPORTANT]
> 最小限の4行だけを記述したTSVをインポートしないでください.
>
> Mozcのキー設定インポートは差分追加ではなく, キーマップ全体の置き換えとして扱われます. `Ctrl+Space`の行しかないTSVをインポートすると, `Space`による変換や候補選択などの標準設定が消えます.

---

## 8. 未入力時のSpaceを半角へ変更する

Mozcプロパティの`一般`タブで, 次を設定します.

```text
一般
  → スペースの入力
  → 半角
```

これにより, IMEが有効な`あ`状態でも, 何も入力していないときの`Space`は半角スペースになります.

キー設定側では, MS-IMEプリセットの次のルールが使用されます.

```text
入力文字なし    Space    空白を入力
```

`空白を入力`は, `スペースの入力`設定に従います.

完全に固定したい場合は, カスタムキー設定で次に変更しても構いません.

```text
入力文字なし    Space    半角空白を入力
```

TSV内部名は次です.

```tsv
Precomposition	Space	InsertHalfSpace
```

通常は, Mozcプロパティの`スペースの入力 → 半角`だけで十分です.

---

## 9. MS-IMEプリセットへCtrl+Spaceを追加する

Mozcプロパティで次を操作します.

```text
一般
  → キー設定
  → 編集...
```

MS-IMEを選択した状態で`編集...`を開きます.

編集内容を保存すると, MS-IMEプリセットを土台とした`カスタム`キー設定になります.

次の4行を追加または変更します.

| モード | 入力キー | コマンド |
|---|---|---|
| 直接入力 | `Ctrl Space` | IMEを有効化 |
| 入力文字なし | `Ctrl Space` | IMEを無効化 |
| 変換前入力中 | `Ctrl Space` | IMEを無効化 |
| 変換中 | `Ctrl Space` | IMEを無効化 |

GUI上のモード名とTSV内部名の対応は次です.

| Mozc GUI | TSV内部名 |
|---|---|
| 直接入力 | `DirectInput` |
| 入力文字なし | `Precomposition` |
| 変換前入力中 | `Composition` |
| 変換中 | `Conversion` |
| サジェスト表示中 | `Suggestion` |
| サジェスト選択中 | `Prediction` |

Ctrl+SpaceのTSV表現は次です.

```tsv
DirectInput	Ctrl Space	IMEOn
Precomposition	Ctrl Space	IMEOff
Composition	Ctrl Space	IMEOff
Conversion	Ctrl Space	IMEOff
```

### 各設定の意味

```text
直接入力
  Ctrl+Space
  → IMEを有効化
```

右上表示を`A`から`あ`へ変更します.

```text
入力文字なし
  Ctrl+Space
  → IMEを無効化
```

IMEが有効で, まだ文字を入力していない状態から`A`へ戻します.

```text
変換前入力中
  Ctrl+Space
  → IMEを無効化
```

未確定文字列を確定してからIMEを無効化します.

```text
変換中
  Ctrl+Space
  → IMEを無効化
```

現在選択中の候補を確定してからIMEを無効化します.

`キャンセル後 IMEを無効化`は, 未確定文字を破棄する可能性があります. 通常は`IMEを無効化`を使用します.

---

## 10. Space関連のキー設定を確認する

キー設定編集画面で, 少なくとも次の設定が存在することを確認します.

| モード | 入力キー | コマンド |
|---|---|---|
| 入力文字なし | `Space` | 空白を入力, または半角空白を入力 |
| 変換前入力中 | `Space` | 変換 |
| 変換中 | `Space` | 次候補を選択 |
| 変換中 | `Shift Space` | 前候補を選択 |
| 変換前入力中 | `Enter` | 確定 |
| 変換中 | `Enter` | 確定 |

TSV内部名では次です.

```tsv
Precomposition	Space	InsertSpace
Composition	Space	Convert
Conversion	Space	ConvertNext
Conversion	Shift Space	ConvertPrev
Composition	Enter	Commit
Conversion	Enter	Commit
```

未入力時のSpaceをキー設定側で半角固定する場合は, 次を使用します.

```tsv
Precomposition	Space	InsertHalfSpace
```

### サジェスト状態

次の2状態に, `Space`や`Ctrl+Space`を重複して設定する必要は通常ありません.

```text
サジェスト表示中
サジェスト選択中
```

専用設定がない場合, Mozcは次の親状態の設定を使用します.

```text
サジェスト表示中
  → 変換前入力中の設定を使用

サジェスト選択中
  → 変換中の設定を使用
```

したがって, 次を設定していれば通常は十分です.

```text
変換前入力中    Space         変換
変換中          Space         次候補を選択
変換前入力中    Ctrl Space    IMEを無効化
変換中          Ctrl Space    IMEを無効化
```

---

## 11. Mozc設定を保存する

キー設定編集画面で`OK`を押します.

Mozcプロパティへ戻ったら, 次を確認します.

```text
キー設定の選択
  → カスタム
```

その後, Mozcプロパティ画面でも`適用`または`OK`を押します.

キー設定編集画面だけを閉じ, Mozcプロパティ側でキャンセルすると, 変更が保存されないことがあります.

---

## 12. GNOME Text Editorで動作確認する

GNOME Text Editorを起動します.

```bash
gnome-text-editor
```

`Super+Space`で`Japanese (Mozc)`へ切り替えます.

### IMEを有効化する

右上表示が`A`の状態で`Ctrl+Space`を押します.

```text
A
  Ctrl+Space
↓
あ
```

### 日本語変換を確認する

次を入力します.

```text
nihongo
```

表示が次になることを確認します.

```text
にほんご
```

`Space`を押します.

```text
にほんご
  Space
↓
日本語
```

もう一度`Space`を押し, 次候補へ進むことを確認します.

```text
日本語
  Space
↓
次の候補
```

`Shift+Space`で前候補へ戻り, `Enter`で確定します.

### 未入力時のSpaceを確認する

右上が`あ`で, 未確定文字がない状態で`Space`を押します.

半角スペースが入力されることを確認します.

### IMEを無効化する

未入力状態で`Ctrl+Space`を押します.

```text
あ
  Ctrl+Space
↓
A
```

### 入力中または変換中にIMEを無効化する

未確定文字列または変換候補がある状態で`Ctrl+Space`を押します.

期待する動作です.

```text
現在の入力または候補を確定
  ↓
IMEを無効化
  ↓
右上がA
```

---

## 13. VS CodeのCtrl+Space競合を解除する

VS Codeでは, Linuxの`Ctrl+Space`が標準で`Trigger Suggest`へ割り当てられています.

Keyboard Shortcutsを開きます.

```text
Ctrl+K Ctrl+S
```

検索欄へ次を入力します.

```text
ctrl+space
```

`Trigger Suggest`の`Ctrl+Space`を削除します.

> [!IMPORTANT]
> ユーザー設定を単にリセットすると, VS Code標準の`Ctrl+Space`へ戻ることがあります.
>
> `keybindings.json`へ明示的な削除ルールを書く方法が確実です.

コマンドパレットから次を開きます.

```text
Preferences: Open Keyboard Shortcuts (JSON)
```

次を追加します.

```json
[
    {
        "key": "ctrl+space",
        "command": "-editor.action.triggerSuggest"
    },
    {
        "key": "ctrl+alt+space",
        "command": "editor.action.triggerSuggest",
        "when": "editorTextFocus && !editorReadonly"
    }
]
```

`command`先頭の`-`は, 標準キーバインドを削除するremoval ruleです.

拡張機能が別の`Ctrl+Space`を登録している場合もあるため, Keyboard Shortcuts画面で同じキーへ割り当てられた全コマンドを確認します.

---

## 14. VS Codeで動作確認する

VS Codeを開き, GNOMEの入力ソースが`Japanese (Mozc)`であることを確認します.

右上が`A`の状態で`Ctrl+Space`を押します.

```text
A
  Ctrl+Space
↓
あ
```

VS Codeのエディターで`nihongo`と入力し, `にほんご`になることを確認します.

`Space`で変換を開始し, もう一度`Space`を押して次候補へ進むことを確認します.

`Ctrl+Space`で`A`へ戻り, VS CodeのSuggestionが表示されないことを確認します.

### VS Codeのキー処理を調査する

コマンドパレットから次を実行します.

```text
Developer: Toggle Keyboard Shortcuts Troubleshooting
```

`Ctrl+Space`を押し, Outputログを確認します.

次のようなログが出る場合は, VS Code側に割り当てが残っています.

```text
matched editor.action.triggerSuggest
```

Keyboard Shortcuts画面で`ctrl+space`を検索し, 他のコマンドや拡張機能の割り当ても解除します.

---

## 15. 完成時の推奨設定

### GNOME

```text
Super+Space
  Japanese (Mozc) ↔ English (US)
```

### Mozc

```text
キー設定の選択
  MS-IMEを土台にしたカスタム設定

スペースの入力
  半角
```

### Ctrl+Space

```text
直接入力        Ctrl Space    IMEを有効化
入力文字なし    Ctrl Space    IMEを無効化
変換前入力中    Ctrl Space    IMEを無効化
変換中          Ctrl Space    IMEを無効化
```

### Space

```text
入力文字なし    Space          空白を入力
変換前入力中    Space          変換
変換中          Space          次候補を選択
変換中          Shift Space    前候補を選択
```

### VS Code

```text
Ctrl+Space
  Trigger Suggestを削除

Ctrl+Alt+Space
  Trigger Suggestへ再割り当て, 任意
```

日常的には`Japanese (Mozc)`を選択したまま, `Ctrl+Space`で`A`と`あ`を切り替えます.

```text
Japanese (Mozc)
  A  ← Ctrl+Space →  あ
```

---

## 16. トラブルシューティング

### mozc_toolが見つからない

次のフルパスで実行します.

```bash
/usr/lib/mozc/mozc_tool --mode=config_dialog
```

ファイルが存在しない場合は, 再インストールします.

```bash
sudo apt install --reinstall mozc-utils-gui
```

### Japanese (Mozc)が表示されない

```bash
sudo apt install --reinstall ibus-mozc mozc-server mozc-data mozc-utils-gui
```

ログアウトしてログインし直します.

IBusがMozcを認識しているか確認します.

```bash
ibus list-engine | grep -i -A4 -B2 mozc
```

### Ctrl+Spaceを押してもAから変わらない

次を確認します.

1. 右上が`en`ではなく`A`になっている.
2. Mozcのキー設定が`カスタム`になっている.
3. `直接入力 / Ctrl Space / IMEを有効化`が存在する.
4. Mozcプロパティ画面で`適用`または`OK`を押した.
5. GNOME側の入力ソース切り替えに`Ctrl+Space`を割り当てていない.
6. VS Codeなどのアプリが`Ctrl+Space`を先に処理していない.

### Aからあにはなるが, あからAへ戻らない

次の設定を確認します.

```text
入力文字なし    Ctrl Space    IMEを無効化
```

### 入力中や変換中だけCtrl+Spaceが効かない

次の2行を確認します.

```text
変換前入力中    Ctrl Space    IMEを無効化
変換中          Ctrl Space    IMEを無効化
```

### IME有効時にSpaceが全角になる

Mozcプロパティで次を設定します.

```text
一般
  → スペースの入力
  → 半角
```

キー設定側で固定する場合は次です.

```text
入力文字なし    Space    半角空白を入力
```

### Spaceで変換できない

次の設定を確認します.

```text
変換前入力中    Space    変換
```

この設定がない場合, 最小TSVなどでキーマップ全体を置き換えてしまった可能性があります.

`キー設定の選択`を`MS-IME`へ戻し, その後`Ctrl+Space`の4行だけをGUIから追加し直します.

### 変換中のSpaceで次候補へ進まない

次の設定を確認します.

```text
変換中    Space    次候補を選択
```

### 候補選択がTabでしかできない

MS-IMEプリセットへ戻し, 次の設定を確認します.

```text
変換前入力中    Space    変換
変換中          Space    次候補を選択
```

### VS CodeだけSuggestionが表示される

`keybindings.json`に次があることを確認します.

```json
{
    "key": "ctrl+space",
    "command": "-editor.action.triggerSuggest"
}
```

Keyboard Shortcuts画面で`ctrl+space`を検索し, 他のコマンドや拡張機能の割り当ても解除します.

---

## 17. キー設定のバックアップ

Mozcのキー設定編集画面から, 動作確認済みの設定をTSVへエクスポートしておくことを推奨します.

ファイル名の例です.

```text
mozc-ubuntu2604-us-keyboard-ctrl-space.tsv
```

将来インポートする場合は, 次を確認します.

1. TSVがMS-IME相当の完全なキーマップを含んでいる.
2. `Ctrl+Space`の4行だけではない.
3. `Composition / Space / Convert`がある.
4. `Conversion / Space / ConvertNext`がある.
5. インポート後, キー設定の選択が`カスタム`になっている.
6. Mozcプロパティ画面で`適用`または`OK`を押した.

---

## 参考資料

- [Ubuntu packages, ibus-mozc](https://packages.ubuntu.com/resolute/ibus-mozc)
- [GNOME Help, Use alternative keyboard layouts](https://help.gnome.org/gnome-help/keyboard-layouts.html)
- [Mozc source, MS-IME keymap](https://github.com/google/mozc/blob/master/src/data/keymap/ms-ime.tsv)
- [Mozc source, Japanese keymap GUI translations](https://github.com/google/mozc/blob/master/src/gui/config_dialog/keymap_ja.qtts)
- [Mozc source, keymap state fallback implementation](https://github.com/google/mozc/blob/master/src/session/keymap.cc)
- [VS Code, Keyboard shortcuts](https://code.visualstudio.com/docs/configure/keybindings)
- [VS Code, Default keyboard shortcuts](https://code.visualstudio.com/docs/reference/default-keybindings)
