# The PR step

*senior-dev reference. Read it after the final report, once the user has reviewed the work.*

Nothing is committed, pushed or opened without the user's yes to the one question below. No answer,
or "Nothing", means nothing happens.

## 1. Prepare

- **The change set:** the files this run changed or created (the state file's "Files changed",
  plus the tests the tester kept in the repo). In Review existing mode, it is the Phase 0 change set
  (the user's work) plus your fixes; say so in the question. Never `git add -A` or `git add .`: the
  tree can hold someone else's work. `.ai-session/` is never staged. A renamed file is staged with
  both its paths; a file git ignores is left out and named in the question.
- **Already staged:** `git diff --cached --name-only`. Staged files outside the change set stay out
  of the commit and stay staged; name them in the question.
- **Nothing to commit:** if no change-set file differs from `HEAD` (the user already committed it,
  for example at a slice checkpoint), there is no commit: the question starts at the push.
- **Working on the target:** if the current branch is the target or the default branch, a pull
  request isn't possible, and a push would go straight to that branch. Offer instead: create a
  branch for the work first (`git switch -c <name>`, named by the project's convention, keeping the
  changes) and then ask the question below; or commit only; or nothing.
- **The commit hooks, before the final runs:** when the repository has hooks that check content
  (a secret scanner, a linter), run them on the change set before the final report's build and
  tests: `pre-commit run --files <change set>`, or the hook tool the repository uses. A rejection
  fixed now doesn't invalidate green runs later. The commit below still runs every hook.
- **The commit message:** the one from the final report, in the repo's convention (Conventional
  Commits when a commit-msg hook or the project's rules require it), written to
  `.ai-session/commit-msg.txt`.
- **The target:** the launch brief's `PR target:` (its `Base:` when that's `none`); without a
  brief, the state's `Base:`.
- **The reviewers:** the project notes' PR reviewers (under Conventions), else the repository's
  CODEOWNERS entries for the changed files; none found, none offered.
- **The host,** from `git remote get-url origin`: `github.com` → GitHub; `dev.azure.com` or
  `visualstudio.com` → Azure Repos; anything else → no pull request from here.
- **The description:** the final report's ready-to-paste PR description, written to
  `.ai-session/pr-body.md`. Title: the commit message's first line. It holds one table row per
  acceptance criterion, `| AC | Addressed / Not addressed / Unclear | Evidence |`, so a reviewer of
  the pull request sees each criterion's status at a glance, and a line `Merge danger: <one-way |
  two-way> door; <blast radius>` taken from the plan's risks and side effects. Anything that sends
  messages, drops or rewrites data, or stores data in a new format is one-way: reverting the commit
  doesn't undo it.
- **The work items:** from the state's `Tracker:` line (a launch brief's `Link PR to` and
  `Review state`). Without a brief: the story's id; the review state is the one the local config or
  the project notes record, or ask for it in the question below.
- **The tracker server:** the state's `Tracker:` server (from the brief's `Source:` line); without
  one, the work-item MCP the local config names. For Azure Repos, the pull request goes through the
  server for the org in the remote URL (`dev.azure.com/<org>/…` or `<org>.visualstudio.com`): the
  tracker server when its org is that one.

## 2. Ask once

Set `Waiting: yes — PR step` in the state. Then one AskUserQuestion call, with the details in its
first question: the files to commit (count and the first few), the commit message,
`push origin <branch>`, `PR <branch> → <target>` on <host>, and "link to <items>; move <id> to
<state>, …" when there are work items and their tracker's MCP server is connected (only the items
`Review state` names move; `none` means no state change).

1. **What to do:**
   - **All:** commit, push, pull request, link and state.
   - **Draft PR:** commit, push, a draft pull request, and the link (no state change).
   - **Commit and push only**
   - **Commit only**, which stops after step 3.1.
   - **Nothing**

   AskUserQuestion takes four options, so leave out the one furthest from the recommendation (the
   user can still type it). The recommendation goes first: the launch brief's `End:` (`pr` → All,
   `push-for-review` → Commit and push only, `local` → Commit only), else All.
2. **The target** (when a pull request is possible): the target first, then the base and the
   default branch where they differ.
3. **Reviewers** (multiSelect): the reviewers found, then **None**. A name the user types is used
   too, and goes in the project notes' PR reviewers, so the next run offers it.

Questions 2 and 3 count only when the answer to 1 opens a pull request.

With the brief's `Approvals: auto`, write the questions to the state and take each first option
without asking. With its `Answers: sprint-lead` (and no `auto`), the three questions go into the
questions file as one `Q-<n>` (`references/launch-brief.md`), and the run waits for the answer.

Set `Waiting: no` after the answer.

## 3. Do what was chosen, in order, stopping at the first failure

1. **Commit:** `git add -- <each file of the change set>`, then
   `git commit -F .ai-session/commit-msg.txt -- <each file of the change set>`, so only those paths
   are committed, whatever else is staged. Hooks run. If a hook rejects the commit, show its output
   and stop: never `--no-verify`, never amend a commit this run didn't make.
2. **Push:** `git push -u origin <branch>`. Never force. If the push is rejected, show why and stop.
3. **Pull request:**
   - GitHub: `gh pr create --base <target> --head <branch> --title "<title>" --body-file
     .ai-session/pr-body.md`, plus `--draft` for Draft PR. If `gh` is missing or not logged in, say
     so, give `https://github.com/<owner>/<repo>/compare/<target>...<branch>`, and stop.
   - Azure Repos: the Azure DevOps MCP server's create-pull-request action (repositories domain,
     for example `repo_pull_request_write` action `create`): source `refs/heads/<branch>`, target
     `refs/heads/<target>`, the title, the body file's text, draft as chosen, and the `Link PR to`
     ids as `workItems`, which links them. If the server or its repositories domain isn't available, say so, give
     `<repository URL>/pullrequestcreate?sourceRef=<branch>&targetRef=<target>`, and stop.
   - Any other host: give the branch and the target, and stop.
   - **Reviewers** chosen: GitHub, `--reviewer <login>,…` on `gh pr create`; Azure Repos, after the
     pull request exists, `repo_pull_request_write` action `update_reviewers`, `reviewerAction:
     add`, with the ids `core_get_identity_ids` gives for each name or email. A reviewer that can't
     be added is said; the pull request stays.
4. **Link and state** (All; Draft PR links only): the tracker server links the pull request to
   each `Link PR to` item step 3 didn't link, then moves each item `Review state` names to its
   state, and no other item. If either isn't available, say so; the pull request stays.
   Jira: link with `createJiraIssueRemoteIssueLink` (the PR's URL and title) only after
   `listJiraIssueRemoteIssueLinks` shows it isn't there (a second call adds a duplicate that can't
   be removed); move with `listJiraIssueTransitions`, then `transitionJiraIssue` with the
   transition whose target status is the review state, since a transition's name can differ.

Record the outcome every time, a stop halfway included: `PR: <url>` (or `none`) in the state, and
the PR line of the chat report and the delivery log: opened (link), draft (link), committed and
pushed only, committed but not pushed (and why), pushed but no pull request (and why), or not
opened.
