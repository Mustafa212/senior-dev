// Applies the reasoning effort that senior-dev's approved plan sets for the current phase.
// The run writes it on its state file's `Effort:` line (.ai-session/senior-dev/<story>.md); this
// hook puts it on every request of the main conversation and shows it in the status line, so the
// user never has to switch it by hand. Subagents keep the effort their dispatch gave them.
import type { EngineInterface, Register } from 'claude-code'

const STATE_DIR = '.ai-session/senior-dev'
const PHASE = /^Phase:\s*(.+?)(?:\s{2,}|$)/m
const EFFORT = /^Effort:\s*(low|medium|high|xhigh|max)\b/m

type Planned = { effort: 'low' | 'medium' | 'high' | 'xhigh' | 'max'; phase: string }

/** The effort on the newest unfinished run's state file, or undefined before a plan sets one. */
async function planned($: EngineInterface): Promise<Planned | undefined> {
  const entries = await $.fs.list(STATE_DIR).catch(() => [])
  const newestFirst = entries
    .filter(entry => entry.kind === 'file' && entry.name.endsWith('.md'))
    .sort((a, b) => b.mtimeMs - a.mtimeMs)
  for (const entry of newestFirst) {
    const text = await $.fs.read(`${STATE_DIR}/${entry.name}`).catch(() => '')
    const phase = PHASE.exec(text)?.[1]
    if (phase === undefined || /DONE/i.test(phase)) continue
    const effort = EFFORT.exec(text)?.[1] as Planned['effort'] | undefined
    return effort === undefined ? undefined : { effort, phase }
  }
  return undefined
}

export const register: Register = on => {
  // What the status line shows now, so a change is announced once.
  let shown: string | undefined

  on('turn.step', async function* ($, e, next) {
    const plan = e.agentId === undefined && e.effort !== undefined ? await planned($) : undefined
    const label = plan && `senior-dev effort: ${plan.effort} (${plan.phase})`
    if (label !== shown) {
      $.ui.status(label)
      if (label) $.ui.toast(label)
      shown = label
    }
    return yield* next(plan ? { ...e, effort: plan.effort } : e)
  })
}
