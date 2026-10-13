# Review and test loop

*senior-dev reference. Read it in Phase 5 before dispatching agents, and in Phase 7 before triage.*

## Dispatching blind review and tests (Phases 5 + 6)

Dispatch the agents with the Agent tool (`subagent_type: general-purpose`), using the models chosen
in the plan. Every agent starts fresh. **Reading runs in parallel, heavy jobs run one at a time:**
launch the reviewer and the tester's design step in one message, because both only read. When the
tests are heavy (a full build, Playwright, an integration suite), only one tester executes at a time,
it runs one command at a time with filtered output, and you don't build while it runs. Agents that
build and test side by side stall each other until the watchdog kills them.

"Blind" means exactly this:

| Give them | Never give them |
|-----------|-----------------|
| the user story or request **verbatim**, the AC, the out-of-scope list, the resolved C-n decisions | your reasoning or why you picked this approach |
| the changed files and the exact diff commands (see the reviewer prompt) | your opinion of the code ("I think it's clean") |
| the paths of the coding rule files in effect | the alternatives you rejected |
| build and run commands, the approved test strategy and proof per AC | the spots you're worried about, framed as hints to find or skip |

- **Reviewer:** fill in `references/reviewer-prompt.md`. It must not edit files.
- **Second reviewer** (optional; only when the plan proposed it and the user approved it, for
  security, money or data-integrity changes): send the same filled reviewer prompt to a reviewer
  from a different model family, if one is configured. For example, with the Codex CLI:
  `codex exec -s read-only -C <repo> -o .ai-session/evidence/round-<n>/second-review.md -`, with the
  prompt on stdin, run in the background. The local config records the exact command. Its findings
  go through the same triage, and a different model family doesn't share Claude's blind spots.
- **Tester:** fill in `references/tester-prompt.md`. Testing happens in three steps:
  1. The tester returns a **test-case table** without writing or running anything.
  2. You compare that table with the **Proof per AC** from the plan (every AC gets the planned
     proof level) and with the risky spots you know about. Send additions with SendMessage, as
     **scenarios only** ("also cover: consent exists for v1 but v2 is current"). Never send expected
     results taken from the implementation, because expected results come from the AC. If an
     expected result is ambiguous, the AC is ambiguous, so take that question to the user.
  3. The tester implements the cases, runs them, including the mutation check where the plan asks
     for it, and returns results with evidence saved under `.ai-session/evidence/round-<n>/`.

  If SendMessage isn't available, have the tester design and execute in a single pass. Then review
  its coverage yourself and dispatch again for any gaps.

## Triage and loop (Phase 7)

Collect the reviewers' findings and the test failures, and **don't apply them blindly**. Reviewers
raise false positives and testers write wrong tests. First check each finding's quoted code against
the file (a quick grep), and discard any whose quote doesn't match. Then check each remaining item
against the actual code, and decide:

- ✅ **Fix:** the issue is real and in scope.
- ❌ **Reject:** give a concrete reason, for example "contradicts the project's architecture rule X".
- ⏸ **Defer:** the issue is real but out of scope; record it as a follow-up.
- ❓ **Ask the user:** any contradiction the reviewer or tester reports between the story and the
  code, the data or the AC. If the story and your AC disagree, your AC is the likely misreading, so
  say so and let the user confirm the fix.
- For a **failing test**, decide whether the code or the test is wrong. The authority is the user
  story, and the AC derived from it. It is never the code, and never the test. Use the tester's
  classification, after checking it yourself:
  - `FUNCTIONAL` and `STORY-TEXT` are bugs in the code. Fix them.
  - `COSMETIC` means the test is coupled to presentation. Fix the test (a stable ID, no assertion
    on text the story doesn't specify), and only when the outcome was verified correct.
  - `ENVIRONMENT` means fix the setup and rerun. It's not a finding against the change.
  - A **surviving mutation** means a test doesn't actually check its AC. Strengthen the test until
    it kills the mutation.

Show the user one triage table:

| # | Source (reviewer / second reviewer / tester) | Severity or class | Finding | Decision (✅ ❌ ⏸ ❓) | Reason |
|---|---|---|---|---|---|

Put every ❓ into a single message, using AskUserQuestion for discrete choices, rather than asking
one at a time. Go ahead with the blocker and major fixes. If a fix would change the approved plan,
an AC, or a product decision, ask first. If the reviewer proposes a fundamentally different approach
and you agree it's clearly better, treat that as a plan change and let the user decide.

**Size the next round to what changed:**
- Fix → build → rerun **every** test related to the touched files, not only the ones that failed,
  so a fix that breaks something else shows up immediately.
- If the round found only minor issues and nits, and every test passed, fix them and stop. A
  re-review adds nothing when no behavior changed.
- Otherwise, re-review with a **fresh** reviewer, scoped to what changed since the last round,
  together with the previous findings so it can confirm each fix. Give it the rejected findings and
  their reasons too; it raises one again only with new evidence. Widen to a full review only when
  the fixes were broad. It still doesn't get your reasoning.

**You're done when all of these hold:**
- The build is green, every related test passes, and the project's full check command passes where
  it defines one.
- Every AC is proven, in Behavior and also in UI where the UI is in scope, with the evidence saved.
- The mutation check passed wherever the plan asked for it.
- No blocker or major findings remain open. Minor findings and nits are either fixed or listed.
- No ❓ is still waiting on the user.

**Hard cap: 3 rounds** (per slice). If round 3 still isn't done, stop and show the user the status and the
options. A loop that won't converge usually means the AC or the approach is wrong, and only the user
can settle that.
