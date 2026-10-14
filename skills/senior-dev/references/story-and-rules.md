# Story and the project's rules

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

## The project's rules

senior-dev ships no coding rules of its own. The code follows the **project's** rules, found in this
order:

1. **ai-standards:** an `AGENTS.md` whose first line says it's managed by ai-standards. Its rules
   are the contract: cite their IDs. Rules marked `[tool]` are enforced by the project's check
   command, so they apply to new and changed lines even where old code breaks them, and that command
   is part of the Phase 3 gate and the done criteria. Managed files and baselined debt are never
   changed inside a story (see Phase 3). A rule that turns out wrong or missing goes upstream through
   ai-standards' own rule-proposal process (`/ai-standards:propose-rule`), never into the project's
   copy.
2. **Other written rules:** a committed `CODING_RULES.md`, an `AGENTS.md` or `CLAUDE.md` that
   defines rules, and the project's linter, analyzer and formatter configs. Cite their IDs where they
   have them, and treat their check commands like the one above.
3. **Nothing written:** follow the conventions the codebase already uses consistently (structure,
   naming, libraries, patterns, error style). If the ai-standards plugin is installed (its skills,
   such as `ai-standards:onboard`, are listed), say once in Phase 1 that onboarding would give the
   project written rules, as a task of its own, never inside a story.

In every case:
- Consistency never means copying defects. Correctness and safety (types, equality, security,
  error handling, resource cleanup) apply to new and changed code even where old code breaks them.
- Change only what the task needs: no drive-by refactors and no reformatting of untouched code.
  Only new and changed lines are judged; violations in untouched code are notes, not findings.
- Phase 1 shows the rules in effect as one line, for example
  `Rules: AGENTS.md (ai-standards, dotnet) — want changes?`, without waiting on a separate answer.
- Never edit a project's rules, or the files that generate them, without the user's OK. Propose
  the change instead.
