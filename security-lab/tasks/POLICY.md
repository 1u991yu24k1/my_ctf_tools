# Local defensive security lab policy

This repository is authorized for defensive analysis.

Allowed:
- Build and test this repository.
- Run sanitizer builds.
- Run fuzzers against local targets.
- Generate minimal regression tests.
- Triage crashes and sanitizer reports.
- Propose defensive patches.
- Write vulnerability reports for maintainers.

Not allowed:
- Access external networks unless explicitly approved.
- Scan third-party systems.
- Generate weaponized exploit chains.
- Add persistence, stealth, or evasion.
- Exfiltrate data.
- Use production secrets.
- Modify files outside this repository.

Output expectations:
- Prefer reproducible commands.
- Prefer minimal patches.
- Include test evidence.
- Clearly separate confirmed facts from hypotheses.
