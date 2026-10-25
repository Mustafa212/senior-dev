import { expect, test } from 'claude-code/testing'

// One request of the main conversation (or of a subagent's loop) at the session's effort.
const STEP = { turnId: 't1', index: 0, model: 'claude-opus-5-5', effort: 'xhigh', messageCount: 3 } as const

function state(phase: string, effort?: string): string {
  return `# S-1 — story\nPhase: ${phase}   Last updated: x\n${effort ? `Effort: ${effort} (why)\n` : ''}NEXT: go\n`
}

// The engine beneath the plugin: a folder of state files, and a model that records the effort it got.
function engine(on: any, files: Record<string, { text: string; mtimeMs: number }>, sent: unknown[]) {
  on('fs.list', () => ({
    value: Object.entries(files).map(([name, f]) => ({ name, kind: 'file', size: 1, mtimeMs: f.mtimeMs, isLink: false })),
  }))
  on('fs.read', (_: unknown, e: { path: string }) => ({ value: files[e.path.split(/[\\/]/).pop()!].text }))
  on('ui.status', () => ({ value: undefined }))
  on('ui.toast', () => ({ value: undefined }))
  on('turn.step', async function* (_: unknown, e: { effort?: unknown }) {
    sent.push(e.effort)
    return { turnId: 't1', index: 0, answer: '', toolUses: [], stopReason: 'end_turn', usage: null }
  })
}

async function step($: any, input: object = STEP) {
  for await (const _ of $.turn.step(input)) { /* the chunks don't matter here */ }
}

test("the newest unfinished run's effort is sent", async ($, on) => {
  const sent: unknown[] = []
  engine(on, {
    'old.md': { text: state('7 — Triage', 'low'), mtimeMs: 1 },
    'done.md': { text: state('DONE', 'max'), mtimeMs: 3 },
    'now.md': { text: state('3 — Implement', 'high'), mtimeMs: 2 },
  }, sent)
  await step($)
  expect(sent).toEqual(['high'])
})

test('before a plan sets an effort, the session keeps its own', async ($, on) => {
  const sent: unknown[] = []
  engine(on, { 'now.md': { text: state('1 — Align'), mtimeMs: 1 } }, sent)
  await step($)
  expect(sent).toEqual(['xhigh'])
})

test("a subagent's request keeps the effort its dispatch gave it", async ($, on) => {
  const sent: unknown[] = []
  engine(on, { 'now.md': { text: state('5 — Review', 'medium'), mtimeMs: 1 } }, sent)
  await step($, { ...STEP, agentId: 'a1' })
  expect(sent).toEqual(['xhigh'])
})
