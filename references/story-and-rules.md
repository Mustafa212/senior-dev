# Story and coding rules

*senior-dev reference. Read it in Phase 0 (steps 3–4) and Phase 1.*

## The user story is the source of truth

The user often sends a **user story**: a description, acceptance criteria, business rules, examples,
sometimes screenshots. When they do, that story is the reference for every agent: you as the
implementer, the reviewer, and the tester. Everything the story specifies must come out exactly as
specified, including behavior, validations, messages, field names, ordering, permissions and edge
cases. The only exception is a contradiction, and the user resolves contradictions, never an agent.
If there's no formal story, the user's written request plays the same role.

- **Fetching a link** (Azure DevOps, Jira, GitHub and so on): use the best tool available, which
  is a work-item MCP if one is configured (the local config names it and records its quirks), and
  otherwise a browser tool on the user's logged-in session. Only read the work item; never edit it,
  even if the tools would allow it. Pull the title, description, acceptance criteria, business
  rules, comments, attachments, and any linked or child items that change the scope. You confirm
  what you pulled with the user in Phase 1, since images and attachments are easy to lose. If you
  can't read the item, ask the user to paste the story.
- **Keep it verbatim.** Save the full story text in the state file, and pass the full text to the
  reviewer and tester alongside your AC. Your AC are your interpretation of the story. If the agents
  get only the AC, any misreading you made reaches them unchecked.
- **Trace it both ways.** Each AC cites its source in the story (`AC-3 ← rule 2`), and every story
  requirement maps to at least one AC unless the user puts it out of scope. Never drop or
  reinterpret a requirement on your own.
- **Surface contradictions and gaps.** Look for contradictions inside the story itself, between the
  story and the existing code, data or business rules, and between the story and the project
  architecture. List each one as `C-1 …`: what conflicts, where (quote the story line and give the
  `file:line`), and the options. Recommend an option, but don't pick it yourself, even when the
  answer seems obvious. If you find a contradiction later, while implementing, reviewing or testing,
  stop and raise it the same way. Stories rarely cover the following, so check each one for a gap:
  who is allowed to do it (roles, ownership); messages and labels in **every** language the app
  supports; audit or history; existing data (migration, old records); existing clients (mobile,
  other frontends, integrations); double submits and concurrency; loading, empty and error states;
  notifications.

## Coding rules

Code produced in this workflow follows one set of rules, so everyone on the team who uses this
skill writes the same way, in every language. There are three levels, and the most specific wins:

1. **Project rules:** `CODING_RULES.md` at the repo root, committed, so everyone who pulls the repo
   (and any AI tool) gets the same rules. If the user doesn't want the file committed in a repo,
   keep them locally in `~/.claude/senior-dev/projects/<project>/rules.md` (see `references/state-and-local-data.md`).
   A committed `AGENTS.md` (or similar instruction file) that already defines rules with IDs, for
   example one generated from a shared standards template, **is** the project rules: don't draft a
   `CODING_RULES.md` next to it or ask the first-run question. Where a default covers the same
   ground, its rule wins and you cite only its ID; the defaults still apply where it is silent (say
   so in the Phase 1 rules line). Rules it marks as tool-enforced (`[tool]`) apply to new and
   changed lines even where old code breaks them, since GEN-CONS-01 can't override a lint gate. If
   it names a full check command (lint, types, tests, coverage), that command is part of the Phase 3
   gate and the done criteria.
2. **Language defaults:** `rules/<language>.md` in this skill, loaded only for the languages the task
   touches: `csharp-dotnet`, `typescript-angular`, `flutter-dart`, `sql-migrations`, `python`. When
   a task touches a language that has no file, say so and follow `general.md` alone.
3. **General defaults:** `rules/general.md`, which always applies.

A project file can override or disable a default by its ID. When a default clashes with a
convention the codebase follows consistently, follow the codebase and say so in Phase 1
(GEN-CONS-01). Project rules always win.

**Asking about rules.**
- *First run on a project* (no project rules in any of these locations): in Phase 1, ask with
  AskUserQuestion whether to use the defaults only, write project rules now, or import an existing
  document. To write them, draft from what the project already enforces (CLAUDE.md, AGENTS.md,
  architecture docs, analyzers, lint config, consistent patterns) using `rules/project-template.md`,
  show the draft, and save it only after the user approves. If the user picks defaults only,
  record that in the project's local `rules.md` so the question isn't asked again.
- *Later runs:* Phase 1 shows a single line, for example
  `Rules: project + C#, SQL defaults — want changes?`, without waiting on a separate answer.

**Every rule has an ID, a level and a reason.** Cite IDs wherever a rule shapes a decision or a
finding. A MUST violation is a major finding and a SHOULD violation is a minor one. The rules are a
team contract: when one turns out wrong or missing, propose the change to the user. Never edit
project or default rules without the user's OK, even under the standing permission in `references/improving.md`.
