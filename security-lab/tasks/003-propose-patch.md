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
