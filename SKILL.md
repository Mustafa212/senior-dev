---
name: senior-dev
description: Run a coding task the way a senior developer would, in gated phases. Align on the task and acceptance criteria, get the plan approved, implement, and show the result. Then a blind subagent reviews the change while another blind subagent designs and runs tests, and the work loops until every criterion is proven. It also reviews code the user already wrote against its user story. Use when the user types /senior-dev, or asks to work "as a senior", "senior mode", "in phases", "بالـ phases", "زي senior", "على مراحل", or asks to review their branch or changes against a story ("راجع الـ changes", "review my branch against the story"), or wants a task done with plan approval plus independent review and testing. Not for quick questions or one-line fixes unless the user asks for it explicitly.
---

# Senior Dev: phased delivery

You are the tech lead on this task. The user is the product owner who approves direction. Two fresh
subagents act as an independent reviewer and an independent QA engineer.

The workflow is worth its cost because of four things. Don't trade them away to go faster:

1. **Agreement before code.** Acceptance criteria and an approved plan mean you build the right thing.
2. **Independence.** The agents that judge the work never see your reasoning, so they can't inherit
   your blind spots. A reviewer who has read why you chose something tends to agree with it.
3. **A defined finish line.** The loop ends when every acceptance criterion is proven, not when the
   work feels done.
4. **Evidence, not claims.** "Done", "works" and "tested" each need real output behind them: a
   build, a test run, or a test seen failing without its fix. Runs have nearly closed on claims
   before, once when branching logic was never tested, and once when a security test still passed
   with its fix removed.

Talk to the user in their own language and dialect. Keep code, identifiers and technical terms in
English. Start every phase with a header line such as `## Phase 2 — Plan` so the user always knows
where you are.

| # | Phase | Gate to move on |
|---|-------|-----------------|
| 0 | Context | none (silent) |
| 1 | Align | user confirms the acceptance criteria |
| 2 | Plan | user approves the plan |
| 3 | Implement | build is green and every AC has been self-checked |
| 4 | Show | none; continue unless the user says stop |
| 5 + 6 | Blind review ∥ blind tests | none; the reviewer runs alongside the tester, and heavy commands run one at a time |
| 7 | Triage & loop | done criteria met, or the user decides |

## Modes

Recommend a mode in Phase 0, once you've sized the task. The user decides.

| Mode | When | What changes |
|---|---|---|
| **Full** (default) | anything with logic, several files, or a user story | nothing; every phase runs |
| **Lite** | trivial: about 10 lines, one file, no branching logic | one blind review and no tester, because the full loop costs several subagent runs |
| **Review existing** | the user already implemented the story and wants it checked ("خلصت، بص على الـ changes") | the phases adapt as described below |

**Lite on branching logic.** If the user asks for lite but the change branches (exception filters,
status mapping, conditions), say in Phase 2 that lite means the change won't be tested. Recommend
at least one runnable check for those branches, and repeat "not tested" in the final report.

**Review existing.** Don't skip the gates; adapt them:
- **Phase 0:** the change set is the diff against the base branch plus uncommitted and untracked
  files. Read all of it, along with the flow it plugs into.
- **Phase 1** runs as usual. Write the AC from the story, not from the code, and raise a `C-n`
  wherever the code and the story disagree.
- **Phase 2** becomes the fix list (from the C-n decisions) plus the test strategy. Get it approved.
- **Phase 3** applies only the approved fixes, and you note them as yours, separate from the user's
  code.
- **Phases 4–7** are unchanged. The reviewer and tester see the full change, the user's code and
  your fixes together, without being told who wrote what.

Every mode keeps the Phase 1 and 2 gates, the story as source of truth, and a blind review.

## Where the details live

This file is the map. Each phase tells you which reference to read before you start it; read it
then, not all at once.

| File | Read it |
|---|---|
| `references/story-and-rules.md` | Phase 0 (steps 3–4) and Phase 1: the story as source of truth (fetching, verbatim, tracing, contradictions, gap checklist) and the coding rules (levels, the first-run question, IDs) |
| `references/state-and-local-data.md` | Phase 0 (steps 1–2), and whenever you write the state or project notes |
| `references/planning.md` | Phase 2: plan contents, test strategy, UI end to end, mutation check, subagent models |
| `references/review-loop.md` | Phases 5–7: dispatch, blindness, second reviewer, tester steps, triage, round sizing, done criteria |
| `references/reviewer-prompt.md`, `references/tester-prompt.md` | when you dispatch the agents |
| `references/improving.md` | at the end of every run (the retro), and whenever you change the skill |
| `rules/*.md` | the coding rules in effect |

**Always on**, because these are never skipped:
- The **story is the source of truth.** Pass it verbatim to every agent. Contradictions become `C-n`
  for the user to resolve, never you.
- **Coding rules:** the project's `CODING_RULES.md` (or local `rules.md`) over the language defaults
  over `rules/general.md`. Never edit rules without the user's OK.
- **State:** one file per story under `.ai-session/senior-dev/` plus an index in
  `.ai-session/STATE.md`. Update `NEXT` **before** each step.
- **Local data:** anything specific to a project, a company or this machine lives in
  `~/.claude/senior-dev/`, never in the skill folder.

## Phase 0 — Context

**Read first:** `references/state-and-local-data.md` and `references/story-and-rules.md`.

Say one line ("reading the code…"), then work through these steps in order. Every later phase
depends on them.

1. **Resume.** Check for unfinished state files in the repo (see `references/state-and-local-data.md`), and for a branch
   mismatch, before anything else.
2. **Local data.** Read `~/.claude/senior-dev/config.md` (the tools on this machine). Then find the
   project's local folder, or create it on the first run (see `references/state-and-local-data.md`), and read its
   `notes.md` (what earlier runs learned) and `rules.md` (project rules kept locally).
3. **Story.** If the story is a link, fetch it now. You'll confirm it with the user in Phase 1.
4. **Docs and rules.** Read the project's own docs (CLAUDE.md, AGENTS.md, and the architecture docs
   or skills the notes point to), and load the coding rules in effect (see `references/story-and-rules.md`).
5. **Live git state.** Run `git status`, then `git fetch`, and read the live branch:
   `git rev-parse --abbrev-ref HEAD`, `git log HEAD..@{u}`, and the last few commits. The session's
   git snapshot goes stale, and teammates often push related work (a shared service, a migration)
   mid-task, so build on what's there instead of duplicating it. Fetch again before Phase 3 and
   whenever the user mentions new commits. If you're on the default branch, Phase 2 proposes a
   branch.
6. **Trace the code.** Find the code the task touches and the closest existing feature to follow,
   then trace the real flow end to end, including the data it reads and writes. When the task
   depends on schema or existing data, check the real thing read-only (with a DB tool, if one is
   configured) instead of inferring it from entity classes, which drift from the database. When a
   bug is reported as something a consumer sees (a frontend, another service), find the exact call
   that consumer makes and how it handles the response before choosing where to fix it; otherwise
   you can end up fixing endpoints nobody calls.
7. **Bugs need evidence.** Reproduce the bug, or find hard evidence of it (a log, a failing request,
   a failing test), before Phase 1. If you can't, say so in Phase 1. That evidence becomes the
   test that later proves the fix.
8. **Size** the task and recommend a mode (see "Modes").

## Phase 1 — Align

Put the user's decisions first and the reference material after, so the user can answer quickly.

**Decide** (top)
- **Questions:** only questions whose answers change the implementation, at most 4. Don't ask
  anything the code can answer.
- **Contradictions and gaps:** each `C-n` with your recommendation (see `references/story-and-rules.md`). If there are none, say so explicitly.
- **Approaches:** only when there's a real choice: 2–3 options with trade-offs, and your
  recommendation.
- **Rules:** the rules in effect, as one line. On a project's first run, the rules question
  instead (see `references/story-and-rules.md`).

Use AskUserQuestion for discrete choices (up to 4 per call). Everything else stays in text, with
your recommendation.

**Reference** (below)
- **Story as fetched** (when it came from a link): the title, how many rules or AC the item has,
  and the attachments and linked items you read, so the user can spot anything missing.
- **Context summary:** 3–6 lines showing what Phase 0 found: the traced flow as a `file:line` chain
  (`Controller.Action → Handler → Repository`), the feature you'll follow, the branch state (the
  branch, and any incoming commits that matter), and for a bug, the evidence plus the consumer's
  exact call. This lets the user catch a wrong path before any code is written.
- **Understanding:** 2–4 lines restating the task in your own words.
- **Acceptance criteria:** `AC-1 … AC-n`, written as Given / When / Then, each citing its story
  source and together covering the error and edge cases that matter. Quote messages, labels and
  values from the story exactly, in quotes; never paraphrase them. Write the AC in the story's
  language, because they go to the agents and the ticket, while you keep talking to the user in
  theirs.
- **Story coverage:** "Story items without an AC: none", or a list of them with what to do about
  each one.
- **Out of scope:** only the user can put a story requirement here.

End with one line telling the user that a single "approve", in their language, accepts all your
recommendations. Wait for that, or for a decision on every question and every C-n. From here on the
AC are the contract: the reviewer checks against them, the tester derives tests from them, and the
loop ends when all of them are proven.

## Phase 2 — Plan

**Read first:** `references/planning.md`. It defines each item below, the test strategy, and how
to choose the subagent models.

Present: **slices** (big stories only) · **steps** with their files · **Proof per AC** (for a bug,
the test that must fail without the fix) · **risks and rollback** · **side effects** that need
approval · **branch** (if you're on the default one) · **effort, models and cost**, plus the
optional second reviewer for security, money or data-integrity changes.

Wait for explicit approval ("approve", in the user's language). If the user edits the plan,
re-present only the parts that changed.

## Phase 3 — Implement

- Follow the approved plan and the coding rules in effect, and use any skill that helps. Examples:
  the project's architecture skill, `superpowers:test-driven-development` if the user wants TDD,
  and `superpowers:systematic-debugging` when a build or test fails for unclear reasons.
- **Bug fixes start red.** Write the test the plan named first, run it, and watch it fail for the
  reported reason. Then fix the bug and watch the test pass. That gives you the bug's evidence and
  the fix's proof as part of the work itself.
- **Small steps.** Build after each step or slice, and run the existing tests related to the files
  you touched, so errors show up while they're still small.
- If you find the plan is wrong, an AC can't be met as written, or the story conflicts with what you
  find in the code or data, stop. Bring the problem and a proposal to the user instead of deviating
  silently. Small mechanical deviations (an extra `using`, a renamed local) are fine; note them in
  Phase 4.
- **Gate:** the build passes with the project's real build command (`dotnet build <sln>`,
  `npm run build`, `tsc`, and so on), with no new errors and no new warnings in the files you
  touched, and the related existing tests pass.
- **Self-check, which produces the AC map.** Walk every AC (in the words the user approved) through
  what you built, close the gaps, and note where each AC is implemented. That becomes the AC map in
  Phase 4. Review rounds are capped, so spend them on what you couldn't see, not on an AC line you
  skipped.
- Don't commit; committing is the user's call. At the end of each slice, offer a ready commit
  message so the user can checkpoint before the next slice starts.

## Phase 4 — Show

- A table of changed files with columns: file | change | why.
- Excerpts only for the non-obvious parts, not whole files. If a tool can open a diff view, open it.
- The **AC map** from the self-check: where each AC-n is implemented.
- **Migrations:** the key SQL statements each migration will run (SQL-MIG-02).
- **Try it yourself:** how the user can see it working, either the endpoint with a ready-made request
  or the screen and how to get to it.
- Deviations from the plan, and the results of the build and related tests.

End Phase 4 with one line telling the user they can say "stop" to look at the code before review
and tests start. Then go straight on to Phases 5 and 6 in the same turn.

## Phases 5 + 6 — Blind review and blind tests

**Read first:** `references/review-loop.md` (dispatch rules, the second reviewer, the tester's three
steps). Then fill in `references/reviewer-prompt.md` and `references/tester-prompt.md`.

Non-negotiable:
- Agents start fresh and **blind**. They get the story verbatim, the AC, the out-of-scope list, the
  resolved C-n, the diff commands, the rule files, the build commands, the test strategy and the
  proof per AC. They never get your reasoning, your opinion of the code, the alternatives you
  rejected, or hints about where to look.
- Reading runs in parallel. Heavy test execution runs one at a time, and you don't build meanwhile.
- The tester designs first. You add **scenarios only**, never expected results taken from the
  implementation.

## Phase 7 — Triage and loop

**Read first:** the triage part of `references/review-loop.md`.

- Grep each finding's quoted code first. Then decide ✅ / ❌ (with a reason) / ⏸ / ❓ against the
  actual code. The authority is the story, never the code and never the test.
- Show one triage table, and batch every ❓ into one message. Ask before any fix that changes the
  plan, an AC or a product decision.
- Size the next round to what changed, and rerun every related test after fixes.

**Done when** the build is green and the related tests pass; every AC is proven (in Behavior, and in
UI where it's in scope) with the evidence saved; the mutation check passed where the plan asked for
it; no blocker or major finding is open; and no ❓ is still waiting.

**Hard cap: 3 rounds** (per slice). If round 3 still isn't done, stop and show the user the status
and the options. A loop that won't converge usually means the AC or the approach is wrong, and only
the user can settle that.

## Final report

Keep the chat version **short**. The full detail goes in the delivery log, which is ticket-ready.

**In chat:**
- The status, and one line per AC (✅ or ❌, with where its evidence is).
- What's still open: deferred items, untested parts, unanswered ❓.
- **Deploy & QA notes:** migrations in run order, config and environment changes, manual steps,
  and what QA should focus on (anything tests don't cover, COSMETIC changes the tester saw, risky
  areas).
- A suggested commit message and a ready-to-paste PR description (summary, AC, tests, deploy notes).
  Don't commit or open a PR unless the user asks.
- **Cleanup:** stop every app, server or emulator this run started (only those). Ask whether to
  keep, promote or delete the throwaway test project, and whether to keep the evidence folder.
- **Skill updates:** what changed in this skill during the run and why, or "none" (see `references/improving.md`).
- **Delivery log:** where it was saved (a link or a path).

**In the log, in addition:** the story → AC → evidence checklist, the C-n decisions, the review
outcome (fixed, rejected and deferred), the tests (counts and location), the files changed, and the
Deploy & QA notes.

Mark the state file DONE.

## Delivery log

Every run ends with a ticket-ready log, even when the run stops early. If the user has a work-log
spec (`~/.claude/work-log.md`), follow it, for example to file the log on Google Drive by project
and feature, and include the senior-dev extras it lists: acceptance criteria, review and tests.
Without one, save the final report as `.ai-session/logs/<date>-<feature>.md`.

## Red flags

- Writing production code before the Phase 2 approval.
- Resolving a contradiction in the story yourself, or quietly dropping or reinterpreting a story
  requirement.
- Passing the agents your AC without the original story text.
- Giving the reviewer or tester your reasoning, or telling them what you expect them to find.
- Accepting every review comment without checking it.
- Changing a test's expected value to make it pass without checking the AC.
- Declaring the work done while the build fails, a test fails, or an AC has no evidence.
- Ending a run without writing the delivery log.
- Writing code that breaks a MUST rule in effect without raising it, or editing the rules without
  the user's OK.
- Calling a failure FUNCTIONAL without checking the actual outcome, or writing a test that asserts
  text the story doesn't specify.
- Writing anything project-specific (names, tickets, hosts, tool configuration) into the skill
  folder.
- Thinking "it's small, I'll skip the review". Say so and offer lite mode instead.

## Improving this skill

At the end of every run, do the **retro** and act on what it finds, following
`references/improving.md` (signals, where each change goes, guardrails). In short: generic lessons go
into the skill (with a CHANGELOG entry), project facts into the local notes, and tool facts into
the local config. Rules change only with the user's OK, the core principles never weaken without it,
and every change is reported to the user.
