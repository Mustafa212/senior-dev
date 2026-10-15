# State file and local data

*senior-dev reference. Read it in Phase 0 (steps 1–2) and whenever you write the state or project notes.*

## State file

The state lets the work continue anywhere: after a crash, in a new session, or in another program
(another AI agent or IDE). Anything not written here doesn't survive.

- **Per story:** `.ai-session/senior-dev/<story-id or slug>.md`, so several stories in one repo (on
  different branches) never overwrite each other.
- **Index:** `.ai-session/STATE.md` lists every unfinished run, one line each with the story, the
  branch, the phase, NEXT, and the path to its file. Many agent setups load this file automatically
  at session start, so another program sees the run without being told. If STATE.md already exists
  for other work, add or update a `## senior-dev runs` section and leave the rest alone. If it
  doesn't exist, create it with that section and a `## NEXT ACTION` line naming the active story.
  Remove a run's line when the run is DONE.
- Before you create `.ai-session/`, check that git ignores it with `git check-ignore -v
  .ai-session/STATE.md`, which also sees `.git/info/exclude` and global excludes. If nothing does,
  ask before you edit `.gitignore`.

**When to write:** update `NEXT` and the step's status **before** each step, not only at phase
transitions, so a crash or a switch of program mid-step still points the right way. Keep the index
line in sync. When you dispatch a background agent (reviewer, tester, second reviewer), record it,
along with what to do if its result never arrives (usually "rerun it"), because another program
can't see your agents. Set `Waiting: yes — <what you asked>` just before you stop for the user (a
gate, a ❓, the PR step) and `Waiting: no` once they answer. `Base` is the branch the work started
from: the launch brief's, or the one you branched from in Phase 2. `PR` is the pull request's URL
once one is opened. An orchestrator reads these three fields to show the user where every run
stands.

```
# <story id> — <title>

> **For any agent picking this up:** this is a senior-dev run, a gated workflow (align on AC →
> approved plan → implement → blind review and tests → triage). Don't write code before the plan is
> approved, and treat the story below as the source of truth. The full workflow is the senior-dev
> plugin's `skills/senior-dev/SKILL.md`, if you can read it. Start from NEXT.

Story: <link or "pasted"> (server: <tracker MCP server, or none>)   Mode: Full | Lite | Review existing   Branch: <branch>
Phase: <n — name>   Last updated: <agent, date time>
NEXT: <the single next action>
Waiting: no   Base: <branch the work started from>   PR: none

## Story (verbatim)
## AC (approved)
## Decisions        C-n → decision; rules in effect; models; second reviewer yes/no
## Plan             steps or slices, each TODO / IN PROGRESS / DONE / BLOCKED
## Files changed    so far, a few words on each
## Agents           dispatched background agents, their status, what to do if lost; file hashes
                   taken before the tester executes
## Rounds           per round: findings → decisions, fixes, test results
## Evidence         paths under .ai-session/evidence/
```

**Resuming.** In Phase 0, read the index and list the unfinished runs. If one matches the story,
summarize where it stopped (its Phase and NEXT) and ask whether to resume or start over. If the
current branch differs from the recorded one, say so before you touch any code. Any agent in any
program resumes the same way: it opens the story's file from the index, follows the header's
gates, and continues from NEXT.

## Local data

This plugin is **generic and public**. Anything specific to a project, a company or this machine
lives outside it, in `~/.claude/senior-dev/`, and never gets copied into the plugin. You create and
maintain these files yourself:

```
~/.claude/senior-dev/
  config.md                      tools on this machine: work-item and DB MCPs and their quirks, work-log spec, OS quirks
  projects/<project>/notes.md    learned facts: commands, test setup, traps, branch naming, docs to read
```

**Every project gets its own folder.** In Phase 0, match the current repo's path or git remote
against the `Repos:` line at the top of each `notes.md`. If nothing matches:
- When the repo clearly belongs to a known project (same remote organization and project, such as
  the frontend of a known backend), ask whether to add it to that project's folder or start a new
  one.
- Otherwise, create `projects/<name>/notes.md` from the skeleton below. Use the remote's repository
  name in kebab-case for `<name>`, or the folder name if there's no remote.

```
# <Project> — local notes
Repos: <local path> (<git remote URL>)[, …]

## Read first        docs or skills to read before coding
## Conventions       branch naming, commit style, build / test / run commands
## Rules             ai-standards AGENTS.md | other written rules (which files) | conventions only
## Facts and traps   one bullet each: the fact, and why it matters
## Test setup        harnesses or templates that worked, and where they live
```

**Record things as you go.** Whenever you learn something specific to the project (a command, a
convention, a trap, a data fact, a test harness, a rules decision), write it to the project's folder
during the run, not just at the end, so a dead session loses nothing. Tool and machine facts (an
MCP's quirk, an OS quirk) go in `config.md`. If you're about to write a project name, ticket number,
internal host, URL or tool configuration into the plugin, it belongs here instead, and only the
general lesson goes into the plugin.

**Keep notes true and small.** Date each new fact. Before relying on a fact that names a file,
function or command, check it still exists, and fix or delete a fact the moment it proves wrong.
Keep each `notes.md` under about 100 lines by merging related facts and dropping stale ones. When a
note is really a team rule (for example "never apply migrations without an explicit OK"), propose
it as a project rule, through ai-standards' rule proposal where the project uses it. That needs the
user's OK, since rules are a team contract.
