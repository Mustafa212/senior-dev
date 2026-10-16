# Modes: Lite and Review existing

*senior-dev reference. Read it before you recommend Lite, and at the start of a run that reviews
code the user already wrote.*

## What Lite proves

With no tester, you are the only one who runs anything, so:
- A bug fix still starts red: you write the test that fails without the fix (Phase 3). There's no
  mutation check.
- Every other AC is proven by the build, the related existing tests, or a check you run yourself.
  Mark that evidence **self-verified** in the final report, because nobody independent ran it.
- If the user asks for Lite but the change branches (exception filters, status mapping,
  conditions), say in Phase 2 that the branches won't be independently tested. Recommend at least
  one runnable check for them, and repeat "not independently tested" in the final report.

## Review existing

Don't skip the gates; adapt them:
- **Phase 0:** the change set is the diff against the base branch plus uncommitted and untracked
  files. Read all of it, along with the flow it plugs into.
- **Phase 1** runs as usual. Write the AC from the story, not from the code, and raise a `C-n`
  wherever the code and the story disagree.
- **Phase 2** becomes the fix list (from the C-n decisions) plus the test strategy. Get it approved.
- **Phase 3** applies only the approved fixes, and you note them as yours, separate from the user's
  code.
- **Phases 4–7** are unchanged. The reviewer and tester see the full change, the user's code and
  your fixes together, without being told who wrote what.
