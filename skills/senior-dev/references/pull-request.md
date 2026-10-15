# The PR step

*senior-dev reference. Read it after the final report, once the user has reviewed the work.*

Nothing is committed, pushed or opened without the user's yes to the one question below. No answer,
or "Nothing", means nothing happens.

## 1. Prepare

- **The change set:** the files this run changed or created (the state file's "Files changed",
  plus the tests the tester kept in the repo). Never `git add -A` or `git add .`: the tree can hold
  someone else's work. `.ai-session/` is never staged.
- **The commit message:** the one from the final report, in the repo's convention (Conventional
  Commits when a commit-msg hook or the project's rules require it), written to
  `.ai-session/commit-msg.txt`.
- **The target:** the launch brief's `PR target:`; without a brief, the state's `Base:`.
- **The host,** from `git remote get-url origin`: `github.com` → GitHub; `dev.azure.com` or
  `visualstudio.com` → Azure Repos; anything else → no pull request from here.
- **The description:** the final report's ready-to-paste PR description, written to
  `.ai-session/pr-body.md`. Title: the commit message's first line.
- **The work item:** the story's id and link, when the run came from a tracker.

## 2. Ask once

Set `Waiting: yes — PR step` in the state. Then AskUserQuestion, with the details in the question:
the files to commit (count and the first few), the commit message, `push origin <branch>`,
`PR <branch> → <target>` on <host>, and "link to <item> and move it to <review state>" when there
is a work item and its tracker's MCP server is connected. Options:

- **All:** commit, push, pull request, link and state.
- **Commit and push only**
- **Draft PR:** commit, push, a draft pull request, and the link (no state change).
- **Nothing**

Set `Waiting: no` after the answer.

## 3. Do what was chosen, in order, stopping at the first failure

1. **Commit:** `git add -- <each file of the change set>`, then `git commit -F .ai-session/commit-msg.txt`.
   Hooks run. If a hook rejects the commit, show its output and stop: never `--no-verify`, never
   amend a commit this run didn't make.
2. **Push:** `git push -u origin <branch>`. Never force. If the push is rejected, show why and stop.
3. **Pull request:**
   - GitHub: `gh pr create --base <target> --head <branch> --title "<title>" --body-file
     .ai-session/pr-body.md`, plus `--draft` for Draft PR. If `gh` is missing or not logged in, say
     so, give `https://github.com/<owner>/<repo>/compare/<target>...<branch>`, and stop.
   - Azure Repos: the Azure DevOps MCP server's create-pull-request action (repositories domain):
     source `refs/heads/<branch>`, target `refs/heads/<target>`, the title, the body file's text, and
     draft as chosen. If the server or its repositories domain isn't available, say so, give
     `<repository URL>/pullrequestcreate?sourceRef=<branch>&targetRef=<target>`, and stop.
   - Any other host: give the branch and the target, and stop.
4. **Link and state** (All; Draft PR links only): the tracker's MCP server links the pull request
   to the work item, then moves the item to the review state. If either isn't available, say so;
   the pull request stays.

Record the outcome: `PR: <url>` (or `none`) in the state, and the final report's PR line: opened
(link), draft (link), committed and pushed only, or not opened.
