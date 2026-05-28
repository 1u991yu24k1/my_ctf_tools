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
