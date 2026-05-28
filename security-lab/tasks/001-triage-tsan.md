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
