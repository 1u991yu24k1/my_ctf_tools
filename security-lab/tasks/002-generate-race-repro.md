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
