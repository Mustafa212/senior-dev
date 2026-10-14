# senior-dev changelog

Newest first. Each entry records what changed and why, generically: no project names or ticket
numbers. Project-specific learnings live in local notes (see "Local data" in SKILL.md).

## 1.2.0 — 2026-10-14 (final review across slices; review package; releases)
- **Final review across slices.** A story that ran in slices ends with one more review of the whole
  change, on the strongest model, with the full story and every AC: one fix pass, then whatever is
  open goes to the user. Why: each slice review saw only its part, so duplicated logic, patterns
  that drifted between slices and parts that don't fit together had no reviewer.
- **Review package.** The main agent writes the whole change (branch commits, uncommitted changes,
  new files) to `.ai-session/evidence/round-<n>/change.diff` and the reviewer reads that file. The
  reviewer now has read and search tools only (Read, Grep, Glob), so it can't edit, build or run
  anything, which the harness enforces. Why: every reviewer sees the same frozen snapshot, the diff
  stays out of the main agent's context, and "don't build" no longer depends on wording.
- **Releases.** Pushing a `vX.Y.Z` tag publishes a GitHub release with that version's section of
  this changelog, after checking that the tag matches `plugin.json`. Tags mark every version from
  1.0.0 on.

## 1.1.0 — 2026-10-14 (tester craft; checks the removed rules used to carry)
- **Tests you can trust** (tester): repeatable (clock, randomness and network controlled, no
  sleeps), independent (own data, any order), one behavior per test, and each test fails without
  what it proves. The project's rules still decide naming, structure and framework. Why: when the
  built-in rules went in 1.0.0, a project with no written test rules left the tester with no
  determinism or isolation baseline.
- **Systematic case design** (tester, Step 1): input classes and boundaries (on, just below, just
  above), a decision table when conditions combine, and allowed plus forbidden state transitions.
  Why: "try to break it" alone gave case lists that depended on what came to mind. A smoke run on a
  boundary bug designed on/below/above cases, caught the bug as FUNCTIONAL, killed 9 of 9 hand
  mutations, and left the code under test byte-identical.
- **Kept from the removed defaults, as workflow:** the reviewer hunts mixed time conventions (UTC
  vs local), public contracts changed beyond the story, secrets or personal data in code, config or
  logs, and swallowed errors, and reads the project's rules before judging conventions. The plan
  names each new dependency with a reason, and a destructive migration states its data impact and
  needs explicit approval (expand → migrate → contract where production data must survive). Why: a
  sentence-by-sentence check of what 1.0.0 removed found these were review and planning checks,
  not project style, and nothing else covered them.

## 1.0.0 — 2026-10-14 (published as a plugin; rules come from the project; audit fixes)
- **Plugin.** The skill is now a Claude Code plugin with its own marketplace (`skills/senior-dev/`,
  `agents/`, `.claude-plugin/`), MIT-licensed. Why: it's the only way to ship real agents, and it
  installs and updates in one command.
- **Real agents for the blind roles.** `senior-dev:reviewer` (it can't edit files) and
  `senior-dev:tester`. Their fixed instructions live in `agents/`, neither loads CLAUDE.md, and the
  main agent fills only a brief (`references/reviewer-brief.md`, `tester-brief.md`). Why: "read
  only" and "blind" were prompt text that a general-purpose agent could ignore, and the user's
  CLAUDE.md (work logs, self-editing) reached the reviewer.
- **No built-in coding rules.** `rules/` (general, language defaults, template), the first-run rules
  question and the local `rules.md` are gone. The project's rules apply: an ai-standards `AGENTS.md`
  first, then other written rules, else the codebase's consistent conventions, with onboarding to
  ai-standards suggested once as a separate task. Severity is set by consequence, not by
  MUST/SHOULD. Why: one source of rules, written into the project and enforced by its tools,
  instead of a second set inside the skill that could disagree with it.
- **The tester executes only after the reviewer returns**, and the main agent snapshots the changed
  production files (`git hash-object -w --no-filters`) before and checks them after. The tester
  never runs `git checkout/restore/stash/reset/clean`, which would destroy the uncommitted change.
  Why: a reviewer reading the same tree saw the tester's files and hand mutations, and a mutation
  left behind went unnoticed.
- **The reviewer doesn't build or run tests**, and gets no build commands. Why: a parallel build
  stalls the tester, which an earlier run hit.
- **Brief slots:** the reviewer gets the planned proof per AC and knows the tests are being written
  in parallel, and the tester gets the out-of-scope list. Why: round 1 flagged every AC as
  "untested", and the tester wrote failing tests for out-of-scope items.
- **Lite defined:** a bug fix still starts red, no mutation check, and other evidence is marked
  self-verified. Why: Lite said "no tester" while other sections required a mutation check and
  independent proof.
- **Quoted line:** one exact line per finding; a quote that doesn't match is checked at its
  `file:line` before it's discarded. Why: multi-line quotes don't fit a table cell, so real findings
  were dropped.
- **Triage checks the tester's tests**, because when only minors are found, no reviewer sees them.
- **Self-edit checks** (leak search against the local project names, pointers resolve, under 500
  lines, core principles present, one scenario for behavior changes), edits only in a git clone and
  never in the plugin cache, changes through pull requests, and skill changes only at the end of a
  run.
- Smaller: the second reviewer's plan line names what it sends to which vendor; Phase 4 says "press
  Esc" instead of "say stop"; the done criteria and round cap live only in SKILL.md; a shorter
  description; `git fetch` before the final report.

## 2026-10-13 (review with the user: projects whose rules come from a standards template)
- **An `AGENTS.md` that defines rules with IDs counts as the project rules** (level 1), for example one
  generated from a shared standards template. No first-run rules question and no `CODING_RULES.md`
  drafted next to it. On overlap its rule wins and only its ID is cited, and the defaults fill only
  the gaps. Its tool-enforced rules apply to new and changed lines even where old code breaks them
  (GEN-CONS-01 can't override a lint gate).
- **A project's full check command** (lint, types, tests, coverage), when it defines one, joins the
  Phase 3 gate and the done criteria. Why: the build plus related tests can be green while the
  project's own gate (coverage, type check) fails in CI.
- Why: the precedence named only `CODING_RULES.md` and local `rules.md`, so in such a project the
  skill would have treated its rules as plain docs. It would have offered to write a duplicate rules
  file, cited default IDs for rules the project already numbers, and followed old conventions where
  the project's linter enforces new ones.
- **Commit messages follow the repo's enforced convention**, and **managed files and baselined debt**
  are never edited inside a story: a blocked managed file becomes a `C-n` (the change goes
  upstream), and baselined debt is a follow-up, never paid or grown in the story. Why: in such a
  repo a run would otherwise propose commit messages the commit-msg hook rejects, or edit around
  a block. The notes skeleton's Rules line gains "AGENTS.md rules".
- The skill folder is now a git repository (it was a plain folder), so self-edits can be reviewed
  and rolled back.

## 2026-10-12 (review with the user, Part 11: restructure for progressive disclosure)
- SKILL.md is now **the map** (590 → 297 lines): principles, modes, a "Where the details live"
  table with an **always-on** summary (story as truth, rules, state, local data), each phase as a
  short checklist with a **Read first** pointer, done criteria and the round cap inline, the final
  report, and red flags.
- Details moved **verbatim** into five references read only at the phase that needs them:
  `story-and-rules.md` (Phases 0–1), `state-and-local-data.md` (Phase 0 and whenever state or notes
  are written), `planning.md` (Phase 2), `review-loop.md` (Phases 5–7), `improving.md` (end of
  run).
- **Verified:** every sentence of the old SKILL.md exists word for word in the new files, except
  the section cross-references renamed to file paths (0 missing after applying the renames). All
  pointer paths resolve, and the folder is still generic. The pre-restructure copy is kept in local
  data (`~/.claude/senior-dev/backups/`).
- Why: a 590-line file read on every run risks details getting lost in the middle. Lite runs and
  early phases now load less, and each phase loads its details right when they're needed.

## 2026-10-12 (review with the user, Part 10: default rules checked against real codebases)
Two real backends and two real Angular frontends were measured against the defaults before any
rule changed.
- **GEN-DATA-03 / CS-TIME-01:** one time convention per system, never mixed. UTC with an injected
  clock for new systems, and existing systems keep their convention. Why: one measured system
  stores local time everywhere, so a "UTC only" rule would have shifted dates silently.
- **CS-NAME-01 split:** casing stays MUST, and the new CS-NAME-02 (Async suffix) is a SHOULD that
  follows the surrounding code, with framework-fixed names exempt. **CS-NULL-01** applies only where
  nullable is enabled.
- **GEN-CONS-01:** consistency covers conventions, never defects. Correctness and safety rules apply
  to new and changed code even when old code breaks them, and old code isn't refactored. The
  reviewer judges only added or modified lines; old violations are notes. Why: one frontend has
  over a thousand `any` and loose `==` uses.
- **NG-RX-01:** one-shot completing observables (HTTP) need no teardown; long-lived streams do. Why:
  a strict reading flagged hundreds of harmless HTTP subscriptions.
- **GEN-TEST-04:** role locators with a name are allowed only when the story specifies the name;
  otherwise `data-testid` is added. Old tests are migrated when they break on text. Why: an
  existing e2e suite locates buttons by their visible (Arabic) labels.
- **SQL-MIG-03:** destructive migrations need explicit approval with their data impact stated, and
  expand/migrate/contract only when production data has to survive. Why: drops and renames are
  routine in the measured migration histories.
- Flutter and Python defaults stay as drafts until a real project is measured.

## 2026-10-12 (review with the user, Part 9 + resuming from another program)
- **Resume from any program:** `.ai-session/STATE.md` is now an **index** of unfinished runs (story,
  branch, phase, NEXT, file), because agent setups commonly auto-load that file at session start.
  An existing STATE.md gets a `## senior-dev runs` section and is otherwise left alone. Each story
  file opens with a "For any agent picking this up" header (the gates in brief, where the full
  skill lives, start from NEXT). NEXT and step status are written **before every step**, and
  dispatched background agents are recorded in an `## Agents` section with what to do if lost. Why:
  the user asked whether they could continue a run from another program. Verified by running a
  session-start hook as another agent, which loaded the index and NEXT.
- **Retro** at the end of every run (what was corrected, what wasted time, what was rediscovered),
  which feeds the "Skill updates" line.
- **Notes hygiene:** facts are dated, verified before use, fixed or deleted when wrong, and kept
  under about 100 lines. A note that's really a team rule is proposed for promotion to the coding
  rules (with the user's OK).
- **Red flags:** calling a failure FUNCTIONAL without checking the outcome, asserting text the story
  doesn't specify, writing project-specific content into the skill folder.
- **Core principles** now include "evidence rather than claims" and "a generic skill folder" (also
  in the global CLAUDE.md).

## 2026-10-12 (review with the user, Part 8: final report, log, state file)
- **State file skeleton** with a `NEXT` line that's updated before acting, so a crash mid-step
  still points the right way.
- **One state file per story** (`.ai-session/senior-dev/<story>.md`), so parallel stories on
  different branches don't overwrite each other. Phase 0 lists the unfinished ones.
- **Branch recorded** in the state, with a warning on resume when the current branch differs.
- **Short chat report**, with the full detail in the ticket-ready log.
- **Deploy & QA notes** (migrations in order, config, manual steps, QA focus) in the report and the
  log.
- **Cleanup:** stop only what the run started, and ask about throwaway tests and evidence.
- **PR description** ready to paste next to the commit message; never posted by Claude.

## 2026-10-12 (review with the user, Part 7: triage and loop)
- **Later rounds are sized to what changed:** if a round finds only minor issues and nits and every
  test passes, fix them and stop without a re-review. Otherwise the fresh reviewer gets the changes
  since the last round plus the previous findings, and widens to a full review only when the fixes
  were broad. Why: full re-reviews of tiny fixes spent usage without new information.
- One fixed **triage table** format (source, severity/class, finding, decision, reason).
- **Rejected findings** go to the next reviewer with their reasons and are raised again only with
  new evidence. Why: to prevent ping-pong across rounds.
- All ❓ questions are batched into one message.
- After fixes, **every** related test is rerun, not only the failing ones (regression check).
- Done criteria updated: related tests pass, every AC proven in Behavior and UI (when in scope)
  with evidence, mutation check passed where planned, no ❓ pending. The round cap is per slice.

## 2026-10-12 (review with the user, Part 6: Phases 5 and 6, prompts)
- **Fix:** the reviewer now sees the whole change (`git diff <base>...HEAD` plus uncommitted and
  untracked files). Before this it saw only uncommitted changes, so committed work went
  unreviewed.
- **Fix:** the reviewer's rules path points to the local project rules (left over from the
  generic/local split).
- **Severity definitions** (blocker / major / minor / nit), with at most 5 nits.
- Every finding **quotes the code exactly**, and triage greps the quote first, discarding findings
  that don't match.
- Parallel vs serial made explicit: reading (the reviewer and the tester's design step) runs in
  parallel, and heavy test execution runs one at a time.
- The tester's design is checked against the plan's **Proof per AC**. Evidence is saved under
  `.ai-session/evidence/round-<n>/` and referenced in the final report.
- The security-test sentence was replaced by the general mutation check.
- **Optional second reviewer** from another model family (for example a read-only Codex CLI) for
  security, money and data-integrity changes. It's proposed in the plan, runs only with the user's
  approval, and goes through the same triage.

## 2026-10-12 (review with the user, Part 5: Phases 3 and 4)
- Bug fixes start red: write the named test first, watch it fail for the reported reason, then fix
  the bug and watch it pass.
- Small steps: build after each step or slice and run the related existing tests. The gate
  includes those tests.
- The AC self-check produces the AC map shown in Phase 4 (deduplicated).
- Phase 4 adds the key SQL of each migration and a **Try it yourself** line (endpoint with a ready
  request, or a screen path).
- Slices end with a ready commit message the user can use as a checkpoint; still no commits by
  Claude.
- Tool-neutral wording for opening a diff view. Moving details into references is planned as a
  final restructuring pass.

## 2026-10-12 (user request: tests that prove functionality, not presentation)
- **Tester:** business rules are proven below the UI, assertions check outcomes, UI elements are
  found by stable IDs, and text is asserted only when the story specifies it. A "try to break it"
  checklist (invalid input, boundaries, roles, double submit, old data, UI states, every language).
  The report shows **Behavior and UI per AC** and classifies each failure as FUNCTIONAL /
  STORY-TEXT / COSMETIC / ENVIRONMENT, with the outcome verified before anything is called
  FUNCTIONAL. Why: the user wants a renamed button never to read as broken functionality, and
  both dimensions shown.
- **Phase 7:** FUNCTIONAL and STORY-TEXT are code bugs. COSMETIC means fixing the test, and only
  once the outcome is verified. ENVIRONMENT means rerun. A surviving mutation means strengthening
  the test.
- **Mutation check** for critical logic and bug fixes (Stryker.NET / StrykerJS / mutmut on the
  changed code, or a hand mutation that's restored right after). Why: a test once passed with its
  fix removed.
- **UI end to end** in the test strategy: a browser tool for the web, and a mobile automation tool
  (for example Maestro MCP) for Flutter or native, with `Semantics(identifier:)` because `Key()`
  isn't visible to automation.
- **Rule GEN-TEST-04** (approved by the user): tests check functionality, not presentation.
- **Reviewer:** a production-bug checklist (races, stale reads, unhandled new enum values, missing
  indexes, tests that don't really check their AC).

## 2026-10-12 (review with the user, Part 4: Phase 2)
- The test strategy moved into Phase 2, where it's decided, and was removed from Phases 5+6.
- **Proof per AC** table in the plan (unit / integration / e2e / manual, and where). For a bug, the
  test that must fail without the fix is named. An AC with no proof is resolved in the plan.
- **Slices** for big stories: each slice owns a subset of the AC and runs Phases 3–7 with its own
  round cap. Why: a multi-slice run worked well, but nothing in the skill described slicing.
- **Rollback** for each risky change, and side effects listed for explicit approval.
- Effort wording is tool-neutral, and an expected-cost line was added (subagent runs per round × max
  rounds).
- "Patterns reused" was removed from Phase 2 because the Phase 1 context summary already names the
  pattern.
- **Choosing subagent models:** the skill picks the cheapest model that can do each role well (the
  reviewer on opus for risky or cross-layer changes, sonnet for small ones; the tester on sonnet,
  opus or haiku by setup difficulty), says why in the plan, and upgrades once if a cheaper model's
  output is shallow. Why: the user asked that the model choose cheaper subagents when they're enough.

## 2026-10-12 (review with the user, Part 3: story and Phase 1)
- The fetched story is confirmed inside the Phase 1 gate ("Story as fetched"), not in a separate
  round trip.
- Phase 1 layout: **Decide** first (questions, C-n, approaches, rules; AskUserQuestion for discrete
  choices), **Reference** after (story as fetched, context summary, understanding, AC, coverage, out
  of scope). One "approve" accepts every recommendation. Why: the decisions were buried in a long
  Phase 1.
- AC are written as Given / When / Then, with story messages and values quoted exactly, in the
  story's language. Why: paraphrased messages are the most common drift from the story.
- "Story items without an AC" line, so coverage is visible both ways.
- A gap checklist for things stories rarely say: permissions, every app language, audit, existing
  data, existing clients, double submit, loading/empty/error states, notifications.
- Story section and Phase 1 deduplicated: principles live in the story section, and Phase 1 only
  sets the output layout.

## 2026-10-11 (user request: the skill owns per-project folders)
- "Local data": every project gets its own local folder, found by matching the repo path or remote
  against a `Repos:` line in `notes.md`. If nothing matches, a repo that belongs to a known project
  (same remote org and project) asks whether to join that folder; otherwise a new folder is created
  from a notes skeleton, named after the remote repo. Project facts are recorded during the run, not
  only at the end. Why: the user wants the generic skill itself to know that anything
  project-specific gets a project folder, and one project can span several repos (API + UI).

## 2026-10-11 (review with the user, Part 2: Phase 0, and a generic/local split)
- **Generic skill, local data:** everything project-, company- or machine-specific moved out of the
  skill folder to `~/.claude/senior-dev/` (`config.md`, `projects/<project>/notes.md` and
  `rules.md`), and the skill creates those files locally. `references/projects/` was removed and
  this changelog rewritten generically. Why: the user wants to publish the skill folder, while
  project and tool details stay private.
- **Phase 0 is an ordered checklist:** resume → local data → story → docs and rules → live git →
  trace → bug evidence → size. Why: the resume and story-fetch steps were scattered in other
  sections.
- **Phase 1 opens with a context summary** (the traced `file:line` flow, the pattern to follow, the
  branch state, and the evidence and consumer call for a bug). Why: in one run a fix landed on
  endpoints no consumer called, and showing the traced path first lets the user catch that before
  coding.
- **Bugs need evidence before Phase 1** (a reproduction, log, or failing request or test). **Data:**
  check the real schema and data read-only instead of inferring them from entity classes.
  **Branch:** on the default branch, Phase 2 proposes one using the project's naming convention.
- Architecture skills for a specific project are named in the local notes, not in SKILL.md.

## 2026-10-11 (user request: shared coding rules + shareable skill)
- New **Coding rules** system with three levels: project `CODING_RULES.md` at the repo root
  (committed, or kept locally), language defaults, and `rules/general.md`. Rules carry IDs,
  MUST/SHOULD levels and reasons. The first run on a project asks about rules; later runs show
  them in one line. Rules feed into Phases 0, 1 and 3, the reviewer (who cites IDs; MUST = major)
  and the tester. Rules change only with the user's OK. Why: teammates who share the skill should
  write the same way across languages, with best-practice defaults.
- Default rule sets: `general`, `csharp-dotnet`, `typescript-angular`, `flutter-dart`,
  `sql-migrations`, `python` (105 rules), plus `project-template.md`. The project file lives at the
  repo root because some repos gitignore `.claude/`.
- **Portability:** the work-item MCP, the work log and the standing permission are optional and
  degrade gracefully. Added `README.md` for humans.

## 2026-10-11 (review with the user, Part 1: frame)
- The description triggers on reviewing existing changes against a story.
- New **Modes** section (Full / Lite / Review existing) gathers what was scattered.
- The phase table matches the lessons learned (the reviewer runs alongside the tester, heavy jobs
  run serially, and Phase 3 includes the AC self-check).
- A 4th core principle, **Evidence, not claims**. Why: runs nearly closed on claims (an untested
  lite change; a security test that still passed with its fix removed).
- Phase 4 ends with a one-line "say stop to inspect first" instead of a hard gate.

## 2026-10-10 (a multi-slice feature run)
- Phase 3: self-check every AC against the build before Phase 4. Why: a self-check found five
  approved-AC gaps that would otherwise have spent a review round.
- Phases 5+6: one heavy job at a time on a local machine. Why: three agents plus a build ran side by
  side and all stalled (watchdog); run serially, they finished.
- Reviewer: where the project requires a security test that fails without its fix, check and prove
  it (remove the fix, run the test). Why: a test written for a data-leak fix still passed with the
  fix removed.

## 2026-10-07 (a lite run on branching logic)
- Lite on a change with branching logic: warn in Phase 2 that it won't be tested, recommend a
  runnable check, and repeat "not tested" in the final report. Why: the user had to ask afterwards
  whether anything was tested.
- Phase 0: when a bug is reported as what a consumer sees, trace that consumer's exact call first.
  Why: the first fix changed endpoints no screen calls.

## 2026-10-07 (a run on a shared branch)
- **Live branch check:** Phase 0 fetches and reads the live branch and incoming commits, and
  repeats this before Phase 3. Why: the session's git snapshot was stale, and the user had to ask
  twice to look at the latest commits.

## 2026-10-06 (first real runs)
- **Review existing code** mode: Phase 1 still writes AC from the story, Phase 2 becomes the fix
  list plus the test strategy, and Phase 3 applies only the approved fixes. Why: mid-run, the user
  said they had already implemented the story and asked for a review.
- **Work log:** every run ends with a ticket-ready log, following the user's work-log spec if one
  exists.
- **Self-improvement:** the "Improving this skill" section and this changelog.
- **Story links:** fetched read-only through a work-item MCP or a browser, and confirmed with the
  user.
- **User story as source of truth:** passed verbatim to the reviewer and tester, every AC traced to
  a story line, contradictions raised as `C-n` for the user to resolve.
- **v1:** the phased workflow (context, align with AC, plan approval, implement with a build gate,
  show, a blind reviewer and blind tester, triage with a 3-round cap), lite mode, a state file,
  effort recommendations.
