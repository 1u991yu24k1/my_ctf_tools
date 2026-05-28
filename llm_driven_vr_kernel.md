agentic security pipeline とは, GitHub Actions / GitLab CI / Jenkins / Buildkite みたいな CI/CD の中に, AI agent が調査, 実験, triage, patch 提案まで行う security workflow を組み込んだもの です.

ただし, 単なる “CI で SAST を回す” ではありません. 違いはここです.

従来の security CI:
  決まった scanner を回す
  結果を SARIF や issue に出す
  人間が読む

agentic security pipeline:
  AI agent が結果を読み,
  仮説を立て,
  必要な追加テストや harness を作り,
  build/test/fuzz/sanitizer を再実行し,
  finding を dedup し,
  再現手順と patch 候補まで作る

つまり, CI/CD + セキュリティツール + LLM agent + sandbox + 人間の承認ゲート です.

具体的にはこういう構成

典型構成はこれです.

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

この中で AI agent は, CI の “1 job” として動くこともあるし, CI から artifacts を受け取る別サービスとして動くこともあります.

GitHub Actions 風に書くと

かなり現実的な最小形はこうです.

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

ここでは AI agent は ./ci/ai-security-agent.sh として抽象化しています. 実体は, OpenAI/Anthropic/ローカルLLM/社内agentのどれでもよいです.

重要なのは, AI に直接 production secret や広い権限を渡さない ことです.

GitLab CI 風なら
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

GitLab でも考え方は同じです.

agentic security pipeline の中身

実際には, いくつかの “loop” が入ります.

1. PR security review loop

PR が来たときに動く軽量ループです.

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

これは毎 PR で回せます.

出力例.

Security review summary:
  Risk: medium
  Suspicious area:
    src/session/cache.cc
  Reason:
    session object lifetime changed, but async callback cancellation path is unchanged.
  Suggested test:
    concurrent close + callback invocation under TSan.
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
