# Review and test loop

*senior-dev reference. Read it in Phase 5 before dispatching agents, and in Phase 7 before triage.*

Contents: Dispatching (Phases 5 + 6) · Triage and loop (Phase 7) · Final review across slices

## Dispatching blind review and tests (Phases 5 + 6)

Dispatch the plugin's agents with the Agent tool: `senior-dev:reviewer` and `senior-dev:tester`,
using the models chosen in the plan. Their instructions live in the agent definitions (`agents/` in
this plugin); you fill only the brief. The reviewer has read and search tools only, so it can't edit,
build or run anything, and neither agent loads the CLAUDE.md files, so a user's or project's working instructions don't reach them. If those agent
types aren't available, dispatch `general-purpose` agents and put the body of the matching file
from the plugin's `agents/` folder above the brief.

**Review package.** Before dispatching a reviewer, write the whole change to one file, so every
reviewer reads the same frozen snapshot and none of the diff enters your own context:

```bash
B=$(git merge-base <base-branch> HEAD); P=.ai-session/evidence/round-<n>/change.diff
F=(<the change set: the state's "Files changed", plus tests kept in the repo>)
mkdir -p "$(dirname "$P")"
{ git diff --stat "$B" -- "${F[@]}"; git diff "$B" -- "${F[@]}"
  git ls-files --others --exclude-standard -- "${F[@]}" |
    while read -r f; do git diff --no-index -- /dev/null "$f"; done
} > "$P"
```

`git diff $B` covers the branch's commits and the uncommitted changes to tracked files; the loop
adds the new files. Limit both to the change set: the working tree can hold someone else's staged
or untracked files, and the reviewer would judge them as part of the change. In Lite mode, append
your self-verified check files too (`git diff --no-index -- /dev/null <file> >> "$P"`, since
`.ai-session/` is ignored), so the one reviewer also judges whether they prove their AC. Then
compare the whole tree with the change set (`git diff --name-only "$B"` and `git status --short`):
list every other file that differs, by name only, in the brief under "Not in the package", so a
file you changed but left out of "Files changed" can't slip past review unseen. Build a fresh
package for every review round.

**Order.** Every agent starts fresh.
1. Launch the reviewer and the tester's design step in one message. Both only read.
2. Compare the tester's design with the plan (step 2 below) while the reviewer works.
3. Let the tester execute only **after the reviewer has returned**. The tester writes test files and
   may mutate production code by hand, and a reviewer reading the same working tree would review
   those as part of the change, or report a mutation as a bug.
4. Before the tester executes, snapshot every changed production file: `git hash-object -w
   --no-filters <files>` (tracked and new files alike), and record the hashes in the state file.
   When the tester returns, run `git hash-object --no-filters <files>` again. A file whose hash
   changed was left modified: restore it with `git cat-file -p <hash> > <file>`, say so in the
   triage, and rerun the related tests.

Heavy jobs run one at a time: when the tests are heavy (a full build, Playwright, an integration
suite), only one tester executes at a time, it runs one command at a time with filtered output, and
you don't build while it runs. Agents that build and test side by side stall each other until the
watchdog kills them. Heavy commands, yours and the tester's, go through the plugin's
`scripts/heavy.sh` (its full path is in SKILL.md, Phase 3; put it in the tester brief), which
serializes them across every session on the machine.

"Blind" means exactly this:

| Give them | Never give them |
|-----------|-----------------|
| the user story or request **verbatim**, the AC, the out-of-scope list, the resolved C-n decisions | your reasoning or why you picked this approach |
| the review package and the list of changed files | your opinion of the code ("I think it's clean") |
| the project's docs and the files that hold its rules | the alternatives you rejected |
| the approved test strategy and the proof per AC; build and run commands to the tester only | the spots you're worried about, framed as hints to find or skip |

- **Reviewer:** fill in `references/reviewer-brief.md`.
- **Second reviewer** (optional; only when the plan proposed it and the user approved it, for
  security, money or data-integrity changes): send the same filled brief, with the body of
  `agents/reviewer.md` above it, to a reviewer from a different model family, if one is configured.
  For example, with the Codex CLI: `codex exec -s read-only -C <repo> -o
  .ai-session/evidence/round-<n>/second-review.md -`, with the prompt on stdin, run in the
  background. The local config records the exact command. Its findings go through the same triage,
  and a different model family doesn't share Claude's blind spots.
- **Tester:** fill in `references/tester-brief.md`. Testing happens in three steps:
  1. The tester returns a **test-case table** without writing or running anything.
  2. You compare that table with the **Proof per AC** from the plan (every AC gets the planned
     proof level) and with the risky spots you know about. Send additions with SendMessage, as
     **scenarios only** ("also cover: consent exists for v1 but v2 is current"). Never send expected
     results taken from the implementation, because expected results come from the AC. If an
     expected result is ambiguous, the AC is ambiguous, so take that question to the user.
  3. Once the reviewer has returned and the snapshot is taken, tell the tester to proceed. It
     implements the cases, runs them, including the mutation check where the plan asks for it, and
     returns results with evidence saved under `.ai-session/evidence/round-<n>/`.

  If SendMessage isn't available, dispatch the tester after the reviewer returns, and have it design
  and execute in a single pass. Then review its coverage yourself and dispatch again for any gaps.

## Triage and loop (Phase 7)

Collect the reviewers' findings and coverage lines and the test failures, and **don't apply them
blindly**. Reviewers raise false positives and testers write wrong tests.

**Incomplete report.** If a report lacks its Verdict, a coverage line, or a finding's Quoted line,
send it back once with SendMessage, asking only for the missing part. Don't fill it in yourself. If
it comes back incomplete again, triage what you have and note the gap.

**Locate, then verify.** Find each finding by its quoted line (a quick grep). If the quote doesn't
match, read the `file:line` it names, and discard the finding only if the problem isn't there. At
that spot, ask whether the harm it describes actually happens, and follow the callers and guards
until you can answer yes or no.

**Coverage lines and earlier findings.** Every story or AC line the reviewer marked `not met`,
`differs` or `unclear` gets a row too, settled from the tester's evidence or a check of your own; an
`unclear` you can't settle leaves that AC unproven. In round 2 and later, a previous finding the
reviewer reports NOT FIXED is open again.

Then decide:

- ✅ **Fix:** the harm is real and in scope: this change caused or exposed it, or the story asks for
  it.
- ❌ **Reject:** you checked, and the harm doesn't happen. The reason names what disproves this
  particular claim; a true fact about the surrounding code that leaves the claim standing doesn't
  count. A finding that is out of scope by a user decision is also ❌, citing that decision.
- ⏸ **Defer:** real, but it was there before this change and is out of scope; record it as a
  follow-up. A defect this change caused is never deferred.
- **Can't tell from the code:** don't guess ✅ or ❌. Give it to the tester as a scenario, or settle it
  with a run of your own. If it's still open after that, defer it with the check that would settle
  it.
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

**Check the tester's tests** that stay in the repo, since no reviewer may see them if this is the
last round: they follow the project's test rules, assert outcomes from the story rather than
presentation, and each one would fail without the behavior it proves. Fix or flag weak ones.

Show the user one triage table:

| # | Source (reviewer / second reviewer / tester) | Severity or class | Finding | Decision (✅ ❌ ⏸ ❓) | Reason |
|---|---|---|---|---|---|

**The severity is yours.** Set it from the consequence you verified, on the reviewer's scale
(`agents/reviewer.md`). When it differs from the reviewer's, show both, for example
`major→minor: <why>`. Lowering a blocker or a major needs the same proof as a reject, because
severity decides whether the loop can end.

Put every ❓ into a single message, using AskUserQuestion for discrete choices, rather than asking
one at a time. Go ahead with the blocker and major fixes. If a fix would change the approved plan,
an AC, or a product decision, ask first. If the reviewer proposes a fundamentally different approach
and you agree it's clearly better, treat that as a plan change and let the user decide.

**Size the next round to what changed:**
- Fix → build → rerun **every** test related to the touched files, not only the ones that failed,
  so a fix that breaks something else shows up immediately.
- If the round found only minor issues and nits (by your triaged severity), and every test passed,
  fix them and stop. A re-review adds nothing when no behavior changed.
- Otherwise, re-review with a **fresh** reviewer, scoped to what changed since the last round
  (including the tests the tester added), together with the previous findings so it can confirm each
  fix. Give it the rejected findings and their reasons too; it raises one again only with new
  evidence. Widen to a full review only when the fixes were broad. It still doesn't get your
  reasoning.

## Final review across slices

When the story ran in slices, review the whole change once more after the last slice is done: a
fresh reviewer on the strongest model, with the full story, every AC, and a review package of the
entire change from the base branch. Each slice review saw one part; this one looks for what only
shows across them, such as duplicated logic, patterns that drifted between slices, and parts that
don't fit together. Its findings go through the same triage. Fix the blockers and majors in one
pass and rerun every related test, then stop: whatever is still open goes to the user in the final
report. There is no second final round.

The done criteria and the round cap are in Phase 7 of `SKILL.md`.
