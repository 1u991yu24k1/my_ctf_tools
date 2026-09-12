# Ubuntu Disk Cleanup Notes

実施日: 2026-09-12

対象: Ubuntu 26.04 x86-64 VM

## 概要

今回の cleanup では, 主に Snap の旧 revision と各種開発ツールの再生成可能な cache, および Claude Code の旧 version を削除した.

実際に大きく効いた対象は, `uv`, Playwright, npm, Bun, Claude Code 旧 version だった.

## 1. Snap

### 1.1 disabled revision

用途:

- Snap 更新後に残っていた旧 revision.
- 現行 revision とは別に保持されていたため, 削除可能だった.

削除コマンド:

```bash
LANG=C snap list --all |
awk '/disabled/ {print $1, $3}' |
while read -r snapname revision; do
    echo "removing $snapname revision=$revision"
    snap remove "$snapname" --revision="$revision"
done
```

今回削除された revision:

```text
core22  2411
core24  1587
snapd   27710
```

注意:

- `awk '$NF == "disabled"'` では, Notes が `base,disabled` や `snapd,disabled` の場合に一致しない.
- `/disabled/` で判定する方がこの環境では適切だった.

### 1.2 Snap download cache

ディレクトリ:

```text
/var/lib/snapd/cache/
```

用途:

- snapd が取得した Snap package の download cache.
- 必要になれば再取得される.

削除コマンド:

```bash
rm -f /var/lib/snapd/cache/*
```

### 1.3 今後の旧 revision 保持数

設定:

```bash
snap set system refresh.retain=2
```

確認:

```bash
snap get system refresh.retain
```

結果:

```text
2
```

用途:

- 今後の Snap refresh 後に保持する revision 数を 2 に抑える.
- 既存の旧 revision を削除する操作ではなく, 将来の肥大化防止用.

## 2. uv cache

ディレクトリ:

```text
/root/.cache/uv
```

用途:

- `uv` が取得した Python package, wheel, source archive, build artifact 等の cache.
- venv 本体やインストール済み package そのものではない.

削除コマンド:

```bash
uv cache clean
```

今回の削除量:

```text
Removed 39631 files (2.6GiB)
```

注意:

- 削除後, 必要な package は再 download される.
- Python virtual environment 自体は削除されない.

## 3. Playwright browser cache

ディレクトリ:

```text
/root/.cache/ms-playwright
```

用途:

- Playwright が利用する Chromium, Firefox, WebKit 等の browser binary.
- 通常の小さな metadata cache ではなく, browser runtime 本体を含むため比較的大きい.

削除コマンド:

```bash
rm -rf /root/.cache/ms-playwright
```

削除前容量:

```text
約646MiB
```

注意:

- 次回 Playwright 利用時に browser の再 install が必要になる可能性がある.
- 必要に応じて以下で再取得する.

```bash
playwright install
```

または環境に応じて,

```bash
uv run playwright install
```

## 4. Electron cache

ディレクトリ:

```text
/root/.cache/electron
```

用途:

- Electron runtime/package の download cache.

削除コマンド:

```bash
rm -rf /root/.cache/electron
```

削除前容量:

```text
約110MiB
```

注意:

- 必要になれば再取得される.

## 5. node-gyp cache

ディレクトリ:

```text
/root/.cache/node-gyp
```

用途:

- `node-gyp` が native addon build 用に取得した Node.js headers 等の cache.

削除コマンド:

```bash
rm -rf /root/.cache/node-gyp
```

削除前容量:

```text
約65MiB
```

注意:

- native addon build 時に必要なものは再取得される.

## 6. pip cache

ディレクトリ:

```text
/root/.cache/pip
```

用途:

- pip の package download cache, wheel cache 等.

削除コマンド:

```bash
rm -rf /root/.cache/pip
```

削除前容量:

```text
約20MiB
```

注意:

- インストール済み Python package は削除されない.
- 必要な package は再 download される.

## 7. npm cache

主なディレクトリ:

```text
/root/.npm/_cacache
```

削除前の内訳:

```text
1.7G  /root/.npm/_cacache
1.8G  /root/.npm
```

用途:

- npm が取得した package tarball や content-addressable cache.
- `node_modules` や現在インストールされている package 本体とは別.

削除コマンド:

```bash
npm cache clean --force
```

削除後:

```text
18M  /root/.npm
```

注意:

- `--force` 使用時に warning が表示されるが, cache cleanup のために実行した.
- package は必要になれば再 download される.
- `/root/.npm/_npx` 約18MiB は今回残した.

## 8. Bun package cache

ディレクトリ:

```text
/root/.bun/install/cache
```

削除前の内訳:

```text
89M   /root/.bun/bin
743M  /root/.bun/install/cache
832M  /root/.bun
```

用途:

- Bun package install 時の package cache.
- `/root/.bun/bin` にある Bun 本体とは別.

削除コマンド:

```bash
rm -rf /root/.bun/install/cache
```

削除前容量:

```text
約743MiB
```

注意:

- Bun 本体は残る.
- package は必要になれば再取得される.

## 9. Claude Code 旧 version

ディレクトリ:

```text
/root/.local/share/claude/versions/
```

削除前:

```text
235M  /root/.local/share/claude/versions/2.1.197
250M  /root/.local/share/claude/versions/2.1.202
205M  /root/.local/share/claude/versions/2.1.251
205M  /root/.local/share/claude/versions/2.1.252
```

現行 version 確認:

```bash
claude --version
readlink -f "$(which claude)"
```

確認結果:

```text
2.1.252 (Claude Code)
/root/.local/share/claude/versions/2.1.252
```

削除コマンド:

```bash
rm -rf \
  /root/.local/share/claude/versions/2.1.197 \
  /root/.local/share/claude/versions/2.1.202 \
  /root/.local/share/claude/versions/2.1.251
```

残した version:

```text
2.1.252
```

削除後:

```text
205M  /root/.local/share/claude
263M  /root/.local
```

注意:

- `claude --version` と `readlink -f "$(which claude)"` で現在使用中 version を確認してから削除する.
- 現行 version のディレクトリは削除しない.

## 10. 今回確認したが削除しなかった主な領域

### Rust toolchain

```text
/root/.rustup  約1.4GiB
```

`rustup toolchain list` の結果, `stable-x86_64-unknown-linux-gnu` 1系統だけだったため, ほぼ現行 toolchain 本体と判断して残した.

### opam

```text
/root/.opam  約1.2GiB
```

`default` switch 1個のみで, 大部分が現行 OCaml environment だったため残した.

### Android SDK / AVD

```text
/root/Android/Sdk/system-images   約3.3GiB
/root/Android/Sdk/emulator        約821MiB
/root/.android/avd/chv_api30.avd  約1.6GiB
```

DriveSec 用 Android emulator environment として実利用中のため残した.

### Snap seed

```text
/var/lib/snapd/seed  約1.6GiB
```

Ubuntu install 時の seed Snap 一式. 通常の cache ではないため, 今回は削除しなかった.

## 11. cleanup 後の確認コマンド

```bash
du -xhd1 /root | sort -h
du -xhd1 / | sort -h
df -h /
```

各 cache の確認例:

```bash
du -sh /root/.cache
du -sh /root/.npm
du -sh /root/.bun
du -sh /root/.local/share/claude
du -sh /var/lib/snapd
```

## 12. 概算回収量

今回の主な削減量は以下.

| 対象 | 概算削減量 |
|---|---:|
| uv cache | 約2.6GiB |
| Playwright cache | 約646MiB |
| Electron cache | 約110MiB |
| node-gyp cache | 約65MiB |
| pip cache | 約20MiB |
| npm cache | 約1.7GiB |
| Bun cache | 約743MiB |
| Claude Code 旧 version | 約690MiB |
| Snap 旧 revision / cache | 数百MiB程度 |

合計では, おおむね 6GiB 超を回収した.

