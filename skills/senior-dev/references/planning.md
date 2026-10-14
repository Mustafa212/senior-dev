# Planning details

*senior-dev reference. Read it in Phase 2, before you present the plan.*

## Plan contents (Phase 2)

Present the following:

- **Slices** (big stories only): when the story has independent groups of AC or spans many layers,
  propose slices. Each slice owns a subset of the AC and goes through Phases 3–7 on its own, with its
  own 3-round cap. The user sees working pieces early, and reviews stay small and sharp.
- **Steps:** in order, each naming its files (new or modified) and what changes in them, following
  the pattern named in Phase 1.
- **Proof per AC:** a table `AC | proven by (unit / integration / e2e / manual) | where`, based on
  the test strategy below. For a bug, name the test that must fail without the fix. An AC with no
  proof is a gap, and you resolve it now, not in Phase 7.
- **Risks and rollback:** migrations, API contract changes, config changes, breaking changes, and for
  each risky one, how to roll it back (a Down migration, a feature flag, keeping the old endpoint
  version).
- **Side effects:** anything that would write to a shared database, send email or other messages, or
  call an external service. Each one needs explicit approval here.
- **Branch:** if you're on the default branch, propose a branch named after the project's convention
  (from the local notes, or else from recent branch names). Create it only after approval.
- **Effort, models and cost:** the reasoning effort you think fits (low / medium / high / xhigh /
  max) and why, for example "high: touches auth across 3 layers". If a tool to change the session
  effort is available, offer to switch it yourself after approval; otherwise ask the user to switch
  it. Name the subagent models you picked (see "Choosing subagent models" below) and the expected cost,
  for example "about 2 subagent runs per round, at most 3 rounds", so the user can weigh Full
  against Lite. For security, money or data-integrity changes, propose the optional second reviewer
  from another model family (see `references/review-loop.md`), and say plainly what it sends where:
  the story, the AC and the diff go to that model's vendor. Some clients don't allow their code to
  leave for another vendor. It runs only if the user approves.

### Choosing a test strategy

Pick the cheapest strategy that actually proves the AC:

1. **The project has a test project:** add the tests there, where they stay as regression tests.
2. **No test project, and the logic is unit-testable** (validators, domain rules, mappers, pure
   services): build a throwaway test project under `.ai-session/tests/<task-slug>/` that references
   the production project and is **not** added to the solution. At the end, ask whether to keep it,
   promote it, or delete it.
3. **The behavior is only visible end to end** (endpoint plus database): run the app locally, call
   the endpoints, and verify state with read-only DB queries, using the project's DB tool if it has
   one. Writes to a shared or dev database need approval in Phase 2, and the tester cleans up
   whatever data it creates.

Mixing strategies is fine, for example unit tests for the rules and one end-to-end run for the
wiring. Whatever the mix, business rules are proven below the UI, and UI tests prove only the
wiring.

**UI end to end**, when an AC is about what the user does or sees:
- **Web:** drive the real app in a browser tool (a built-in browser, Playwright, or a DevTools MCP,
  whichever is configured), and keep screenshots as evidence.
- **Mobile (Flutter, native):** drive the app on an emulator or simulator with a mobile automation
  tool (for example the Maestro MCP) if one is configured. Interactive widgets need
  `Semantics(identifier:)`, because Flutter's `Key()` isn't visible to UI automation. If no tool is
  configured, say so in the plan and propose setting one up, recorded in the local config.

**Mutation check** for critical logic (security, money, data integrity, and any bug fix in Full
mode): the plan names it, and the tester proves the tests catch a broken implementation. Use the language's
mutation tool on the changed code only (Stryker.NET for C#, StrykerJS for TS/JS, mutmut for Python),
since full runs are slow. If the tool isn't installed, ask before installing it as a local or dev
tool, or have the tester mutate by hand (break the logic, run the tests, restore it).

### Choosing subagent models

You decide which model each subagent (`senior-dev:reviewer`, `senior-dev:tester`) gets, choosing
the cheapest one that can do the job well, and you state the choice and the reason in the plan. The
user can override it.

- **Reviewer:** this is the judgment-heavy role. Use the strongest model (`opus`) when the change
  touches security, money, data integrity or concurrency, spans several layers, or the story is
  subtle. A small, mechanical change in one layer can use `sonnet`.
- **Tester:** `sonnet` for straightforward cases (clear inputs and outputs, an existing harness).
  `opus` when the setup is hard (a new harness, a mocked chain, tricky data) or the logic is subtle.
  `haiku` only for rerunning an existing suite and reporting the results.
- **Upgrade instead of accepting a shallow result.** If a cheaper model's output looks thin (generic
  findings, obvious paths missed, happy-path-only tests), dispatch that role again once with a
  stronger model. Record the choice and any upgrade in the state file.
