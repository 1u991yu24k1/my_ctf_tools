# Agentic security pipeline

GitHub Actions / GitLab CI / Jenkins / Buildkite みたいな CI/CD の中に, 
AI agent が調査, 実験, triage, patch 提案まで行う security workflow を組み込んだもの.

ただし, 単なる “CI で SAST を回す” ではなく以下の点で異なる.

* **従来の security CI**
  1. 決まった scanner を回す
  2. 結果を SARIF や issue に出す
  3. 人間が読む

* **agentic security pipeline**
  1. AI agent が結果を読み,
  2. 仮説を立て,
  3. 必要な追加テストや harness を作り,
  4. build/test/fuzz/sanitizer を再実行し,
  5. finding を dedup し,
  6. 再現手順と patch 候補まで作る

つまり, CI/CD + セキュリティツール + LLM agent + sandbox + 人間の承認ゲート です.

## 具体的なWF構成

典型構成はこれです.
```
GitHub / GitLab
  |
  | push, PR, nightly, dependency update
  v
CI runner
  |
  +-- build matrix
  |     normal
  |     ASan/UBSan
  |     TSan
  |     fuzz
  |
  +-- static analysis
  |     CodeQL
  |     Semgrep
  |     clang-tidy
  |
  +-- dynamic analysis
  |     unit tests
  |     sanitizer tests
  |     fuzzing
  |     stress tests
  |
  +-- trace/replay, optional
  |     rr / rr.soft
  |     core dump
  |     perf/ftrace logs
  |
  +-- AI security agent
        |
        +-- logs を読む
        +-- crash を分類
        +-- suspicious code を読む
        +-- repro を縮小
        +-- patch 候補を作る
        +-- GitHub issue / PR / SARIF に出す
        +-- high-risk は人間レビューへ
```

この中で AI agent は, CI の “1 job” として動くこともあるし, 
CI から artifacts を受け取る別サービスとして動くこともあります.

かなり現実的な最小形はこうです.
```yaml
name: agentic-security

on:
  pull_request:
  push:
    branches: [ main ]
  schedule:
    - cron: "0 18 * * *"

permissions:
  contents: read
  security-events: write
  issues: write
  pull-requests: write

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        mode: [normal, asan-ubsan, tsan]
    steps:
      - uses: actions/checkout@v4

      - name: Install deps
        run: ./ci/install-deps.sh

      - name: Configure
        run: ./ci/configure.sh ${{ matrix.mode }}

      - name: Build
        run: ./ci/build.sh

      - name: Test
        run: ./ci/test.sh
        continue-on-error: true

      - name: Collect artifacts
        if: always()
        run: ./ci/collect-artifacts.sh ${{ matrix.mode }}

      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: security-artifacts-${{ matrix.mode }}
          path: artifacts/

  static-analysis:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run Semgrep
        run: semgrep scan --config auto --json -o artifacts/semgrep.json
        continue-on-error: true

      - name: Run CodeQL
        run: ./ci/run-codeql.sh
        continue-on-error: true

      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: static-analysis-artifacts
          path: artifacts/

  fuzz-short:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build fuzz targets
        run: ./ci/build-fuzzers.sh

      - name: Run short fuzzing
        run: ./ci/run-fuzzers.sh --timeout 300
        continue-on-error: true

      - name: Collect crashes
        if: always()
        run: ./ci/collect-fuzz-artifacts.sh

      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: fuzz-artifacts
          path: artifacts/

  ai-triage:
    needs: [build-and-test, static-analysis, fuzz-short]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - uses: actions/checkout@v4

      - uses: actions/download-artifact@v4
        with:
          path: artifacts-in/

      - name: Run AI security triage
        run: ./ci/ai-security-agent.sh \
          --repo . \
          --artifacts artifacts-in \
          --output artifacts-out/security-report.md \
          --sarif artifacts-out/security.sarif \
          --mode defensive-triage

      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: ai-security-report
          path: artifacts-out/

      - name: Upload SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: artifacts-out/security.sarif
```

ここでは AI agent は ./ci/ai-security-agent.sh として抽象化しています. 
実体は, OpenAI/Anthropic/ローカルLLM/社内agentのどれでもよいです.

重要なのは, AI に直接 production secret や広い権限を渡さない ことです.

GitLab CI 風なら
```yaml
stages:
  - build
  - test
  - analyze
  - fuzz
  - ai_triage
  - report

variables:
  ARTIFACT_DIR: artifacts

build:asan:
  stage: build
  image: ubuntu:24.04
  script:
    - ./ci/install-deps.sh
    - ./ci/configure.sh asan-ubsan
    - ./ci/build.sh
  artifacts:
    when: always
    paths:
      - build/
      - artifacts/

test:tsan:
  stage: test
  image: ubuntu:24.04
  script:
    - ./ci/install-deps.sh
    - ./ci/configure.sh tsan
    - ./ci/build.sh
    - ./ci/test.sh || true
    - ./ci/collect-artifacts.sh tsan
  artifacts:
    when: always
    paths:
      - artifacts/

static:semgrep:
  stage: analyze
  image: returntocorp/semgrep
  script:
    - semgrep scan --config auto --json -o artifacts/semgrep.json || true
  artifacts:
    when: always
    paths:
      - artifacts/

fuzz:short:
  stage: fuzz
  image: ubuntu:24.04
  script:
    - ./ci/install-deps.sh
    - ./ci/build-fuzzers.sh
    - ./ci/run-fuzzers.sh --timeout 300 || true
    - ./ci/collect-fuzz-artifacts.sh
  artifacts:
    when: always
    paths:
      - artifacts/

ai:triage:
  stage: ai_triage
  image: ubuntu:24.04
  dependencies:
    - test:tsan
    - static:semgrep
    - fuzz:short
  script:
    - ./ci/install-agent-deps.sh
    - ./ci/ai-security-agent.sh
        --repo .
        --artifacts artifacts
        --output artifacts/security-report.md
        --mode defensive-triage
  artifacts:
    when: always
    paths:
      - artifacts/security-report.md
      - artifacts/security.sarif
```

GitLab でも考え方は同じです.

## agentic security pipeline の中身

実際には, いくつかの “loop” が入ります.

1. PR security review loop

PR が来たときに動く軽量ループです.

```yaml
trigger:
  pull_request

inputs:
  diff
  changed files
  dependency changes
  previous findings
  unit test results
  SAST result

agent tasks:
  変更差分を読む
  dangerous pattern を探す
  missing validation, auth bypass, race, lifetime bug を疑う
  追加テストを提案
  high-risk change に label を付ける
```
これは毎 PR で回せます.

出力例.
```markdown
Security review summary:
  Risk: medium
  Suspicious area:
    src/session/cache.cc
  Reason:
    session object lifetime changed, but async callback cancellation path is unchanged.
  Suggested test:
    concurrent close + callback invocation under TSan.
```

2. Nightly deep analysis loop

夜間に重い検査を回します.

trigger:
  nightly

tasks:
  ASan/UBSan full test
  TSan full test
  fuzzing 6〜12時間
  dependency scan
  differential analysis
  AI triage

これは時間がかかるので PR ではなく nightly にします.

3. Fuzzing + AI triage loop

fuzzer が crash を出したら, AI が分類します.

crash input
  |
  v
dedup
  |
  v
stack trace
  |
  v
AI triage
  |
  +-- likely duplicate
  +-- likely false positive
  +-- likely security relevant
  +-- needs minimization

AI agent はここで,

この crash は既知 issue と同じか
どの commit で入ったか
入力を縮小できるか
ASan/UBSan/TSan のどれで再現するか
security impact がありそうか

を判断します.

4. Race-specific loop

race 系なら別ループを持ちます.

TSan report
  |
  v
AI reads stack traces
  |
  v
identify shared object / field
  |
  v
generate threaded reproducer
  |
  v
run with seed, yield injection, stress
  |
  v
collect logs
  |
  v
minimize repro
  |
  v
propose lock/lifetime patch

ここで重要なのは, seed と operation log を必ず残す ことです.

seed: 0x8f33a991
threads: 4
iterations: 100000
yield_prob: 3%
operation_log: artifacts/repro-001.ops

これがないと, AI も人間も再現できません.

5. Patch proposal loop

検出だけで終わらせず, patch まで持っていきます.

finding
  |
  v
AI proposes patch
  |
  v
build
  |
  v
unit test
  |
  v
sanitizer test
  |
  v
regression test
  |
  v
human review

ここは重要です. agentic security pipeline の価値は, finding 数ではなく, fix までの throughput です.

## ユーザランドOSSライブラリ向けSuite

```yaml
Build:
  clang, cmake, ninja, bear

Static:
  CodeQL
  Semgrep
  clang-tidy
  ripgrep + AI review

Dynamic:
  TSan
  ASan
  UBSan
  libFuzzer
  AFL++

Concurrency:
  custom threaded harness
  randomized yield/sleep
  stress-ng
  taskset

Replay:
  rr
  rr.soft
  gdb

Trace:
  perf sched
  trace-cmd
  bpftrace

AI:
  harness generation
  TSan triage
  root cause hypothesis
  reproducer minimization
  patch review
```

## AI workflow
以下のようなローカルマシンで動作するVR labを作成する.

```
host machine
  |
  +-- target repo <- ターゲットのソースリポジトリ. 
  |
  +-- security-lab/
        |
        +-- docker/
        |     Dockerfile.sanitize <- Sanitizer付きビルド. (ASAN, UBSAN, TSAN) 
        |     Dockerfile.fuzz     <- fuzzer を安全かつ再現可能に走らせるための専用コンテナ定義
        |
        +-- scripts/
        |     build-normal.sh
        |     build-asan.sh
        |     build-tsan.sh
        |     run-tests.sh
        |     run-fuzz.sh
        |     collect-artifacts.sh
        |     make-task.sh
        |
        +-- artifacts/
        |     tsan.log
        |     asan.log
        |     fuzz-crashes/
        |     stacktraces/
        |     repro/
        |
        +-- tasks/
        |     001-triage-tsan.md
        |     002-generate-repro.md
        |     003-propose-patch.md
        |
        +-- reports/
              finding-001.md
              patch-review.md
```

セットアップ. 
```shell
sudo apt update
sudo apt install -y \
  clang lld llvm cmake ninja-build git python3 python3-venv \
  gdb lldb valgrind \
  clang-tidy \
  ripgrep jq \
  docker.io docker-compose \
  stress-ng \
  trace-cmd \
  linux-tools-common

# Fuzzingも入れる場合. 
sudo apt install -y afl++ libclang-rt-dev
```

### 必要ディレクトリの準備
```shell
mkdir -p security-lab/{scripts,artifacts,tasks,reports,fuzz,patches}
```

`.gitignore`は以下

```gitignore
security-lab/artifacts/
security-lab/reports/*.raw.md
security-lab/fuzz/corpus/
security-lab/fuzz/crashes/
```

ただし, ただし, reproducible task や patch は commit 対象にしてよい
```
security-lab/tasks/
security-lab/scripts/
security-lab/reports/finding-*.md
```

### sanitizer build script を作る
* `security-lab/scripts/build-asan.sh`

```shell
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$ROOT/build-asan"

cmake -S "$ROOT" -B "$BUILD" -G Ninja \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_C_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer -g" \
  -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer -g" \
  -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address,undefined" \
  -DCMAKE_SHARED_LINKER_FLAGS="-fsanitize=address,undefined"

cmake --build "$BUILD"
```

* `security-lab/scripts/build-tsan.sh`
```shell
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$ROOT/build-tsan"

cmake -S "$ROOT" -B "$BUILD" -G Ninja \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_COMPILER=clang \
  -DCMAKE_CXX_COMPILER=clang++ \
  -DCMAKE_C_FLAGS="-fsanitize=thread -fno-omit-frame-pointer -g" \
  -DCMAKE_CXX_FLAGS="-fsanitize=thread -fno-omit-frame-pointer -g" \
  -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=thread" \
  -DCMAKE_SHARED_LINKER_FLAGS="-fsanitize=thread"

cmake --build "$BUILD"
```

### test 実行と artifacts 収集
* `security-lab/scripts/run-tests.sh`

```shell
#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-tsan}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BUILD="$ROOT/build-$MODE"
OUT="$ROOT/security-lab/artifacts/$MODE"

mkdir -p "$OUT"

export TSAN_OPTIONS="halt_on_error=0 history_size=7 second_deadlock_stack=1 log_path=$OUT/tsan"
export ASAN_OPTIONS="halt_on_error=0 detect_leaks=1 log_path=$OUT/asan"
export UBSAN_OPTIONS="halt_on_error=0 print_stacktrace=1 log_path=$OUT/ubsan"

ctest --test-dir "$BUILD" --output-on-failure 2>&1 | tee "$OUT/ctest.log" || true

find "$OUT" -type f -maxdepth 1 -print > "$OUT/files.txt"
```

実行は以下. 
```shell
chmod +x security-lab/scripts/*.sh

./security-lab/scripts/build-tsan.sh
./security-lab/scripts/run-tests.sh tsan

./security-lab/scripts/build-asan.sh
./security-lab/scripts/run-tests.sh asan
```

### task fileを作って agent に渡す
ここが重要です. Claude Code / Codex に渡す “仕事” を markdown で固定する. 

スコープ, 禁止事項, 入力, 出力 を明示します.

* `security-lab/tasks/001-triage-tsan.md`
```shell
# Task: TSan finding triage

You are working on an authorized local repository.

Scope:
- Defensive vulnerability research only.
- Do not create weaponized exploit code.
- Do not access the network.
- Do not modify files outside this repository.
- Do not change public API unless necessary.
- Prefer minimal patches and regression tests.

Inputs:
- security-lab/artifacts/tsan/
- security-lab/artifacts/tsan/ctest.log
- Source tree in this repository.

Goals:
1. Identify distinct TSan reports.
2. Group duplicate reports.
3. For each distinct report, identify:
   - shared object or field,
   - read stack,
   - write stack,
   - missing synchronization or lifetime bug,
   - likely security relevance.
4. Write a report to:
   - security-lab/reports/tsan-triage.md

Do not patch yet.
```

Codexに渡す場合は以下. 
```shell
codex --sandbox workspace-write --ask-for-approval on-request \
  "Read security-lab/tasks/001-triage-tsan.md and complete it."
```

Claude Codeに渡す場合
```shell
claude --auto-mode -p 'Read security-lab/tasks/001-triage-tsan.md and complete it.'
```

### repro生成タスクを渡す
* `security-lab/tasks/002-generate-race-repro.md`
```markdown
# Task: Generate a minimal race reproducer

Scope:
- Authorized local defensive research only.
- Do not create exploit chains.
- Do not attempt privilege escalation.
- Do not access external network.
- Keep the reproducer as a regression test.

Inputs:
- security-lab/reports/tsan-triage.md
- security-lab/artifacts/tsan/
- Source tree.

Goals:
1. Select the highest-confidence race report.
2. Create a minimal regression test that triggers the race under TSan.
3. The test must accept:
   - --seed
   - --threads
   - --iterations
   - --yield-prob
4. It must print the seed and operation log path.
5. Add the test under the existing test framework if possible.
6. Run the test under TSan.
7. Write reproduction steps to:
   - security-lab/reports/repro-001.md

Constraints:
- No network.
- No destructive system operations.
- Minimal code changes.
```

Codexは以下のように渡す. 
```shelll
codex --sandbox workspace-write --ask-for-approval on-request \
  "Read security-lab/tasks/002-generate-race-repro.md and complete it."
```

Claude Codeには以下のように渡す. 
```shell
claude --auto-mode -p "Read security-lab/tasks/002-generate-race-repro.md and complete it."
```

### patch タスク (修正パッチを当てる場合)

```markdown
# Task: Propose a minimal defensive patch

Scope:
- Authorized local defensive research only.
- Do not create weaponized exploit code.
- Do not attempt bypasses or persistence.
- Do not access external network.

Inputs:
- security-lab/reports/tsan-triage.md
- security-lab/reports/repro-001.md
- The reproducer added in the previous task.

Goals:
1. Explain the root cause.
2. Propose a minimal patch.
3. Add or update a regression test.
4. Run:
   - normal tests,
   - TSan test,
   - ASan/UBSan test if relevant.
5. Save:
   - security-lab/reports/finding-001.md
   - security-lab/patches/finding-001.patch

Constraints:
- Prefer locking, lifetime ownership, or atomic discipline fixes.
- Avoid broad rewrites.
- Do not suppress TSan unless you can prove the race is benign.
```

実行後, 人間で diffを確認. 
```shell
git diff 
git diff > security-lab/patches/finding-001.patch
```

### ローカル Sandbox をDockerで切る. 
* `security-lab/docker/Dockerfile.sanitize`
Agent がローカルで, ASan/TSan/UBSan 付きで通常テストを回す環境

```Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    clang lld llvm cmake ninja-build git python3 python3-venv \
    gdb lldb valgrind clang-tidy ripgrep jq stress-ng trace-cmd \
    afl++ ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /work
```

ビルド
```shell
docker build \
  -f security-lab/docker/Dockerfile.sanitize \
  -t local/security-lab:sanitize .
```

実行, 
```shell
docker run --rm -it \
  --network none \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  -v "$PWD:/work" \
  local/security-lab:sanitize \
  bash
```

### Codex / CC に Taskを渡す現実解

Fuzzingのログやビルドのログをサマライズして, AI に食わせる. 
* `security-lab/
```python
#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
ARTIFACTS = ROOT / "security-lab" / "artifacts"
REPORTS = ROOT / "security-lab" / "reports"

SANITIZER_PATTERNS = [
    ("asan", re.compile(r"ERROR: AddressSanitizer: (?P<kind>[^\n]+)")),
    ("tsan", re.compile(r"WARNING: ThreadSanitizer: (?P<kind>[^\n]+)")),
    ("ubsan", re.compile(r"runtime error: (?P<kind>[^\n]+)")),
    ("msan", re.compile(r"WARNING: MemorySanitizer: (?P<kind>[^\n]+)")),
]

STACK_LINE = re.compile(r"^\s*#\d+\s+0x[0-9a-fA-F]+.*$", re.MULTILINE)


def read_text(path: Path, limit: int = 2_000_000) -> str:
    try:
        data = path.read_bytes()[:limit]
        return data.decode("utf-8", errors="replace")
    except OSError as exc:
        return f"<failed to read {path}: {exc}>"


def summarize_log(path: Path) -> dict[str, Any]:
    text = read_text(path)
    findings: list[dict[str, Any]] = []

    for sanitizer, pattern in SANITIZER_PATTERNS:
        for match in pattern.finditer(text):
            start = max(0, match.start() - 1000)
            end = min(len(text), match.end() + 6000)
            excerpt = text[start:end]
            stack = STACK_LINE.findall(excerpt)[:20]
            findings.append(
                {
                    "sanitizer": sanitizer,
                    "kind": match.groupdict().get("kind", "").strip(),
                    "offset": match.start(),
                    "stack": stack,
                    "excerpt": excerpt[:8000],
                }
            )

    return {
        "path": str(path.relative_to(ROOT)),
        "size_bytes": path.stat().st_size,
        "findings": findings,
    }


def main() -> None:
    REPORTS.mkdir(parents=True, exist_ok=True)

    log_files = []
    if ARTIFACTS.exists():
        for path in ARTIFACTS.rglob("*"):
            if path.is_file() and path.suffix in {".log", ".txt", ""}:
                if path.stat().st_size > 0:
                    log_files.append(path)

    summaries = [summarize_log(path) for path in sorted(log_files)]

    summary_json = {
        "artifact_root": str(ARTIFACTS.relative_to(ROOT)),
        "log_count": len(log_files),
        "logs": summaries,
    }

    out_json = ARTIFACTS / "summary.json"
    out_json.parent.mkdir(parents=True, exist_ok=True)
    out_json.write_text(json.dumps(summary_json, indent=2), encoding="utf-8")

    lines: list[str] = []
    lines.append("# Artifact summary")
    lines.append("")
    lines.append(f"- Artifact root: `{ARTIFACTS.relative_to(ROOT)}`")
    lines.append(f"- Logs scanned: {len(log_files)}")
    lines.append("")

    total_findings = sum(len(item["findings"]) for item in summaries)
    lines.append(f"- Sanitizer findings: {total_findings}")
    lines.append("")

    for item in summaries:
        if not item["findings"]:
            continue
        lines.append(f"## `{item['path']}`")
        lines.append("")
        for i, finding in enumerate(item["findings"], 1):
            lines.append(f"### Finding {i}: {finding['sanitizer']} / {finding['kind']}")
            lines.append("")
            if finding["stack"]:
                lines.append("Stack excerpt:")
                lines.append("")
                lines.append("```")
                lines.extend(finding["stack"][:12])
                lines.append("```")
                lines.append("")
            lines.append("Log excerpt:")
            lines.append("")
            lines.append("```")
            lines.append(finding["excerpt"][:3000])
            lines.append("```")
            lines.append("")

    out_md = REPORTS / "artifact-summary.md"
    out_md.write_text("\n".join(lines), encoding="utf-8")

    print(f"Wrote {out_json}")
    print(f"Wrote {out_md}")
    print(f"Sanitizer findings: {total_findings}")


if __name__ == "__main__":
    main()
```

このスクリプトは以下の内容をサマライズする. 

* どの job が失敗したか
* どの sanitizer が反応したか
* どの stack trace があるか
* crash artifact はどこか
* 再現コマンドは何か

```shell
chmod +x security-lab/scripts/summarize-artifacts.py
./security-lab/scripts/summarize-artifacts.py # artifact-summary
```

Agent には以下のように読ませる.

```
Read security-lab/reports/artifact-summary.md first.
Then inspect only the referenced logs and source files needed for triage.
```

方式 A. CLI に task file を読ませる

一番シンプルです.

codex --sandbox workspace-write --ask-for-approval on-request \
  "Read security-lab/tasks/001-triage-tsan.md and complete it."

Claude Code.

claude
Read security-lab/tasks/001-triage-tsan.md and complete it.
方式 B. GitHub issue / PR 経由

Claude Code GitHub Actions は, GitHub PR や issue 上で質問に答えたりコード変更を実装したりする action として提供されています. GitHub も Claude や Codex などの coding agents を GitHub の workflow に統合する Agent HQ を public preview として出しています.

ローカルで完結したいなら CLI の方が安全ですが, チーム運用なら issue/PR 経由が便利です.

方式 C. MCP 経由

Claude Code は MCP を使えます. Claude Code の update でも /mcp から computer-use を toggle する説明があり, CLI から外部ツール連携できる方向に拡張されています.

自前で MCP server を作るなら, agent にこういう tool だけ見せます.

* `run_tsan_tests`
* `run_asan_tests`
* `run_fuzzer`
* `read_artifact`
* `write_report`
* `create_patch`

逆に, arbitrary shell を直接渡さない設計にできます.

最初に作るべき MCP 風 API

本格 MCP 実装まで行かなくても, まずは Python CLI で十分です.

* `security-lab/scripts/labctl`
```shell
#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-}"

case "$CMD" in
  build-tsan)
    ./security-lab/scripts/build-tsan.sh
    ;;
  build-asan)
    ./security-lab/scripts/build-asan.sh
    ;;
  test-tsan)
    ./security-lab/scripts/run-tests.sh tsan
    ;;
  test-asan)
    ./security-lab/scripts/run-tests.sh asan
    ;;
  summarize)
    python3 security-lab/scripts/summarize-artifacts.py
    ;;
  *)
    echo "Usage: $0 {build-tsan|build-asan|test-tsan|test-asan|summarize}" >&2
    exit 2
    ;;
esac

```

agent にはこう指示します.

```
Use only ./security-lab/scripts/labctl for build and test commands unless you ask for approval.
```


これだけで暴走をかなり防げます.

#### Agentに渡すべき情報と, 渡さない情報

渡す情報は以下. 
* source code
* build logs
* sanitizer logs
* stack traces
* core dump backtrace
* fuzz input
* reproducer
* operation log
* commit diff

渡さない情報は以下.

* production secrets
* customer data
* private keys
* cloud credentials
* live internal network access
* unredacted crash dumps with sensitive data
* third-party target credentials 


このコンテナ内で, sanitizer / fuzz / testを走らせる. 
Codex / CC 自体を Container内で動かすか, host 側で agent を動かして container 実行コマンドだけ許可するかは好み. 

> [!Tips]
> 最初は, Agent @ host 側, containered test がハンドリングしやすい. 
```
Codex / CC:
  host 上で, repoを読む. 

Build / Test / Fuzz
  docker run --network none で実行する. 
```

* `security-lab/docker/Dockerfile.fuzz`

Fuzzing の実行に寄せたコンテナ. 

ビルド. 
```shell
docker build \
  -f security-lab/docker/Dockerfile.fuzz \
  -t local/security-lab:fuzz \
  .
```

実行 (network noneで安全にしておくのが良い)
```shell
docker run --rm -it \
  --network none \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  -v "$PWD:/work" \
  local/security-lab:fuzz \
  bash
```
> $PWD を host とコンテナで共有しているので, fuzz の ログ, クラッシュ入力は見える. 



## FAQ
### Codex / Claude Codeどちらが良い?
Claude Code / Codex のどちらが優れているかを固定せず, 役割を分けると安定します.

例えば以下のような役割分担. 

```
Agent A:
  artifact triage
  root cause analysis
  report 作成

Agent B:
  repro / regression test / patch 作成

Agent C, あるいは同じ agent の別セッション:
  patch review
  false positive review
```

### race 用 harness の標準仕様


race 系なら, すべての repro にこの CLI を要求する. 
```
--seed <SEED>
--threads <THREAD_NUM> 
--iterations <ITER_NUM>
--yield-prob <JOB_NUM>
--operation-log <LOG_PATH>
```
例.

```
./build-tsan/tests/race_repro_session_cache \
  --seed 0x41414141 \
  --threads 4 \
  --iterations 100000 \
  --yield-prob 3 \
  --operation-log security-lab/artifacts/repro/session-cache.ops.json
```

agent にもこう指示します.
```
A race reproducer is not acceptable unless it prints the seed, thread count, iteration count, and operation log path.
```
これを徹底すると, AI が作る repro の品質がかなり上がります.


### 安全な権限設定
Codexなら, 以下. 

```shell
codex --sandbox workspace-write --ask-for-approval on-request
```
[公式 reference](https://developers.openai.com/codex/cli/reference) でも, 
ローカル作業の低摩擦設定として workspace-write と on-request が示されています.

Claude Code 側も, コマンド実行やファイル変更で許可確認が入る設計です.
```
```

### 最小限でスターとするには?
```
Step 1:
  ASan/UBSan build script

Step 2:
  TSan build script

Step 3:
  run-tests.sh で artifacts 保存

Step 4:
  tasks/001-triage-tsan.md を作る

Step 5:
  Codex に triage させる

Step 6:
  Claude Code に triage report をレビューさせる

Step 7:
  Codex に regression test を作らせる

Step 8:
  人間が diff と test result を確認
```

実際の運用コマンド例
```shell
# 1. clean
rm -rf build-tsan build-asan security-lab/artifacts/*

# 2. produce artifacts
./security-lab/scripts/build-tsan.sh
./security-lab/scripts/run-tests.sh tsan
./security-lab/scripts/build-asan.sh
./security-lab/scripts/run-tests.sh asan

# 3. ask Codex for triage
codex --sandbox workspace-write --ask-for-approval on-request \
  "Read security-lab/tasks/POLICY.md and security-lab/tasks/001-triage-tsan.md. Complete the task."

# 4. ask Claude Code for independent review
claude
# then:
# Review security-lab/reports/tsan-triage.md against the source tree.
# Write security-lab/reports/tsan-triage-review.md.
# Do not modify source files.

# 5. generate repro
codex --sandbox workspace-write --ask-for-approval on-request \
  "Read security-lab/tasks/002-generate-race-repro.md. Use finding #1 from security-lab/reports/tsan-triage.md."

# 6. inspect
git diff
cat security-lab/reports/repro-001.md
```
