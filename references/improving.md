# Improving this skill

*senior-dev reference. Read it at the end of every run (the retro) and whenever you change the skill.*


This skill learns from real runs. Whenever a run shows that something should be added or changed,
and the change would help future runs, improve it. If the user has given standing permission (for
example in their CLAUDE.md), edit the skill files directly and then tell them what changed.
Otherwise, propose the change and apply it once they approve. If the skill folder is a git repo,
remind the user to commit and push, so teammates who share the skill pull the same version.

**Retro at the end of every run** (about a minute, before the final report). Answer three
questions: What did the user correct, or have to ask twice? What wasted time? What did you have to
rediscover? Each answer becomes a skill change, a line in the project's notes, or "none". Their
outcome is the "Skill updates" line of the final report.

**Signals worth acting on:**
- The user corrected you, or had to repeat a request. That correction belongs in the skill.
- A phase confused you, was skipped, or wasted time without adding value.
- The reviewer raised false positives or missed something real, or the tester guessed expected
  results, gave weak coverage, or fumbled the test setup. Fix the prompt in `references/`.
- You had to rediscover a project fact that earlier runs already learned (a build command, how to
  test this codebase, a trap in the code or data).

**Where each change goes:**
- Workflow changes that apply to any project go in `SKILL.md` or `references/*.md`, and are
  written generically.
- Project facts (commands, traps, test setup) go in the project's local `notes.md`, and tool or
  machine facts go in the local `config.md`, never in the skill folder (see `references/state-and-local-data.md`). Notes
  aren't rules; rules change only through the coding rules (`references/story-and-rules.md`).
- Every change to the skill folder gets a dated entry in `CHANGELOG.md`: what changed and why,
  described generically ("a run where…"), with no project names or ticket numbers.

**Guardrails:**
- Generalize. Write the lesson, not the one case, so the fix still helps on the next ten tasks.
- Keep the skill lean. When you add something, look for something that no longer pulls its weight
  and cut it, so the skill doesn't bloat.
- The core principles change only with the user's explicit OK. They are: user approval at Phases 1
  and 2, the story as the source of truth, blind review and testing, evidence rather than claims,
  triage before applying, the 3-round cap, the delivery log, and a generic skill folder. You may refine how they're carried out, but you may not weaken them.
- Tell the user every change, in the final report or right away if it happened mid-run. A change
  that never gets reported is not allowed.
