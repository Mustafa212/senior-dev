# senior-dev — a Claude Code skill (for humans)

Claude works through a coding task the way a senior developer would: align on acceptance criteria →
you approve the plan → implement → show → a **blind** reviewer and a **blind** tester check the work
against the user story → loop until everything is proven. All of it follows **shared coding rules**,
so everyone on the team writes the same way in every language.

`SKILL.md` is written for Claude. This file is for you.

## Install

Pick one:
- **Git (recommended for a team).** Clone this repo into `~/.claude/skills/senior-dev`, and run
  `git pull` regularly. The skill improves itself from real runs, so commit and push those changes
  to keep everyone on the same version.
- **Copy the folder.** Copy `senior-dev/` into `~/.claude/skills/`. It's simple, but copies drift
  apart over time.

Then start a new Claude Code session and type `/senior-dev <task, story text, or work-item link>`.

## Generic skill, local data

This folder is generic and safe to publish. Everything specific to your projects, company or machine
is created by the skill **locally** and never goes into this folder:

```
~/.claude/senior-dev/
  config.md                      your tools: work-item / DB MCPs and their quirks, work-log spec, OS quirks
  projects/<project>/notes.md    what runs learned about a project: commands, test setup, traps, branch naming
  projects/<project>/rules.md    project rules kept locally, if you don't commit CODING_RULES.md
```

**Optional extras.** The skill works without them and skips whatever is missing.
- A work-item MCP (for example `@azure-devops/mcp`) to fetch stories from links. Keep it read-only by
  denying its write tools in `settings.json`.
- A work-log spec at `~/.claude/work-log.md` (for example, logs on Google Drive). Without it, the
  log is saved to `.ai-session/logs/`.
- Standing permission for Claude to improve the skill on its own, granted in `~/.claude/CLAUDE.md`.
  Without it, Claude proposes each change and waits for your approval.

## Modes
- **Full** (default): every phase runs.
- **Lite:** a trivial change gets one blind review and no tester.
- **Review existing:** "review my branch against this story" checks code you already wrote.

## Coding rules

There are three levels, and the most specific wins:

| Level | Where | Who changes it |
|---|---|---|
| Project | `CODING_RULES.md` at the repo root, committed (template: `rules/project-template.md`) | the team, through a PR |
| Language | `rules/csharp-dotnet.md`, `typescript-angular.md`, `flutter-dart.md`, `sql-migrations.md`, `python.md` | proposed by Claude, approved by you |
| General | `rules/general.md` | proposed by Claude, approved by you |

- Every rule has an ID (`CS-ASYNC-01`), a level (**MUST** = major finding, **SHOULD** = minor) and a
  reason. Reviews cite rule IDs, so discussions stay concrete.
- A project file can override or disable a default by its ID.
- On the first run in a project, the skill asks whether you want project rules. It can draft them
  from what the repo already does, for you to approve. After that it shows the rules in effect as
  one line.

## Files
```
SKILL.md                            the map: principles, modes, phases as short checklists, gates, red flags
references/story-and-rules.md       read in Phases 0–1: story as source of truth, contradictions, coding rules
references/state-and-local-data.md  read in Phase 0: state file / index (resume from any program), local data
references/planning.md              read in Phase 2: plan contents, test strategy, mutation check, models
references/review-loop.md           read in Phases 5–7: blind dispatch, second reviewer, tester steps, triage
references/improving.md             read at the end of a run: retro and how the skill evolves
references/*-prompt.md              prompts for the blind reviewer and tester
rules/                              default coding rules + project template
CHANGELOG.md                        every change to the skill, with the reason (written generically)
```
