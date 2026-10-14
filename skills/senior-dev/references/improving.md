# Improving this skill

*senior-dev reference. Read it at the end of every run (the retro) and whenever you change the skill.*

This skill learns from real runs. Whenever a run shows that something should be added or changed,
and the change would help future runs, improve it. If the user has given standing permission (for
example in their CLAUDE.md), edit the files directly and then tell them what changed. Otherwise,
propose the change and apply it once they approve.

**Where to edit.** Only in a git clone of the plugin: the folder a local marketplace points to, or
the user's fork. If the skill runs from the plugin cache (a path under `~/.claude/plugins/cache/`),
don't edit it there, because the next update overwrites it. Propose the change to the user instead,
as an issue or a pull request to the plugin's repository. Make the changes on a branch, so they reach
other users through a pull request, never by a direct push to `main`.

**Retro at the end of every run** (about a minute, before the final report). Answer three
questions: What did the user correct, or have to ask twice? What wasted time? What did you have to
rediscover? Each answer becomes a skill change, a line in the project's notes, or "none". Their
outcome is the "Skill updates" line of the final report. Change the skill only at the end of a run,
never mid-run, so one run never mixes two versions of the workflow.

**Signals worth acting on:**
- The user corrected you, or had to repeat a request. That correction belongs in the skill.
- A phase confused you, was skipped, or wasted time without adding value.
- The reviewer raised false positives or missed something real, or the tester guessed expected
  results, gave weak coverage, or fumbled the test setup. Fix the agent definition in `agents/` or
  the brief in `references/`.
- You had to rediscover a project fact that earlier runs already learned (a build command, how to
  test this codebase, a trap in the code or data).

**Where each change goes:**
- Workflow changes that apply to any project go in `SKILL.md`, `references/*.md` or `agents/*.md`,
  written generically.
- Project facts (commands, traps, test setup) go in the project's local `notes.md`, and tool or
  machine facts go in the local `config.md`, never in the plugin (see
  `references/state-and-local-data.md`).
- Coding rules aren't part of this skill; they belong to the project (see
  `references/story-and-rules.md`).
- Every change to the plugin gets a dated entry in `CHANGELOG.md`: what changed and why,
  described generically ("a run where…"), with no project names or ticket numbers. Bump the
  version in `.claude-plugin/plugin.json` when the change is released.

**Check every change before you report it:**
1. Nothing private leaked. Search the plugin for the names of the local project folders, for
   example `grep -rniwE "$(ls ~/.claude/senior-dev/projects | paste -sd'|')" <plugin root>`, and
   for hosts, paths, org names and ticket numbers you saw during the run.
2. Every file that `SKILL.md` and the references point to exists.
3. `SKILL.md` stays under 500 lines.
4. The core principles below are all still stated.
5. When the change alters behavior (a gate, a rule for the agents), run one scenario that would
   have failed before the change on a fresh subagent with the changed text, and check that it now
   passes.

**Guardrails:**
- Generalize. Write the lesson, not the one case, so the fix still helps on the next ten tasks.
- Keep the skill lean. When you add something, look for something that no longer pulls its weight
  and cut it, so the skill doesn't bloat.
- The core principles change only with the user's explicit OK. They are: user approval at Phases 1
  and 2, the story as the source of truth, blind review and testing, evidence rather than claims,
  triage before applying, the 3-round cap, the delivery log, and a generic plugin. You may refine
  how they're carried out, but you may not weaken them.
- Tell the user every change, in the final report. A change that never gets reported is not
  allowed.
