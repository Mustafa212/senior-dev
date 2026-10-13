# General defaults (GEN)

These apply in every language. Language files and the project's `CODING_RULES.md` can override
any of them by ID.
**MUST**: breaking it is a major review finding. **SHOULD**: breaking it is a minor finding, and
deviating needs a stated reason.

## Consistency and scope
- **GEN-CONS-01 (MUST)** Follow the **conventions** the codebase already uses (structure, naming,
  libraries, patterns, error style) over personal preference. When a default rule clashes with a
  consistent convention, follow the codebase and say so. *Why:* a consistent codebase is cheaper
  to read than one that's locally perfect. Consistency never means copying **defects**: rules about
  correctness and safety (types, equality, security, error handling, resource cleanup) apply to new
  and changed code even when old code breaks them. Old code isn't refactored as a side effect
  (GEN-SCOPE-01), and pre-existing violations in untouched lines are noted, not counted as
  findings.
- **GEN-SCOPE-01 (MUST)** Change only what the task needs: no drive-by refactors and no reformatting
  of untouched code in the same change. *Why:* the diff stays reviewable and the blast radius stays
  small.
- **GEN-SCOPE-02 (SHOULD)** Don't build speculative abstractions: no interface with one
  implementation, no config for a value that never changes, no scaffolding "for later".
- **GEN-REUSE-01 (MUST)** Search the repo for an existing helper, service or component before
  writing a new one.

## Design and naming
- **GEN-DESIGN-01 (SHOULD)** Give each function or class one responsibility. If describing it
  needs "and", split it. Use guard clauses and early returns, and keep nesting to 3 levels or
  fewer.
- **GEN-NAME-01 (MUST)** Names say what a thing is or does, in domain language. Use no abbreviations
  except universal ones (id, url, dto), and write booleans as questions (`isActive`, `hasConsent`).
- **GEN-NAME-02 (MUST)** No magic numbers or strings. Name them as constants, enums or config.

## Errors and validation
- **GEN-ERR-01 (MUST)** Never swallow an error: no empty catch, and no catch-and-continue. Catch
  only what you can actually handle, and let everything else reach the central handler.
- **GEN-ERR-02 (MUST)** Validate input at the trust boundaries (API, message consumers, file and
  user input) and fail fast with a clear message. Trust internal calls.
- **GEN-ERR-03 (SHOULD)** Messages shown to users are user-facing, localized where the app is
  localized, and never contain stack traces or internal details.

## Security
- **GEN-SEC-01 (MUST)** Keep secrets out of code, committed config, logs and URLs. Use the
  project's secret store or environment.
- **GEN-SEC-02 (MUST)** Every endpoint or action checks authorization, including ownership (users
  can only touch their own records), not just authentication.
- **GEN-SEC-03 (MUST)** Never build queries, commands or HTML by concatenating untrusted input. Use
  parameters or encoders.
- **GEN-SEC-04 (MUST)** Never log or return sensitive data: passwords, tokens, national IDs, full
  card numbers.

## Data
- **GEN-DATA-01 (MUST)** Writes that have to succeed together run in one transaction.
- **GEN-DATA-02 (SHOULD)** An unbounded read is a bug. Page or limit list endpoints and queries.
- **GEN-DATA-03 (MUST)** Use one time convention per system and never mix conventions. New systems
  store and compare UTC, convert only at the edges, and inject the clock so code can be tested. An
  existing system keeps the convention it already uses. *Why:* writing UTC into a system whose
  stored times are local shifts dates by hours and silently breaks comparisons.
- **GEN-API-01 (MUST)** Never change a public contract (API shape, DB columns, message schema)
  silently. Version it, or name it as a breaking change in the plan.

## Tests
- **GEN-TEST-01 (MUST)** Every branch of new business logic has a test: the happy path, each error
  path, and the boundaries.
- **GEN-TEST-02 (MUST)** A bug fix comes with a test that fails without the fix.
- **GEN-TEST-03 (MUST)** Tests are deterministic: no real clock, randomness, network or shared
  state unless it's controlled. Test one behavior per test, and name it with the scenario and
  the expected result.
- **GEN-TEST-04 (MUST)** Tests check functionality, not presentation. Prove business rules below the
  UI (API, handler, service), and assert outcomes (state, data, response). UI tests find elements by
  stable IDs (`data-testid`, `Semantics(identifier:)`), adding them to the template as part of the
  change. A role locator with a name (`getByRole('button', { name })`) is allowed only when the
  story specifies that name. Assert text only when the story specifies it. Existing tests aren't
  rewritten, but one that breaks on changed text is classified COSMETIC and migrated to a stable ID.
  *Why:* renaming a button must never read as broken functionality, and a broken outcome must never
  hide behind a UI that looks right.

## Hygiene
- **GEN-FMT-01 (MUST)** The code passes the project's formatter, linter and analyzers with no new
  warnings.
- **GEN-COMM-01 (SHOULD)** Comments explain *why*, not *what*. Delete commented-out code, and give
  every TODO a ticket or an owner.
- **GEN-LOG-01 (SHOULD)** Log at boundaries and on failures, with context (IDs, the operation) and
  in structured form. Don't both log and rethrow the same error.
- **GEN-PERF-01 (SHOULD)** No queries or remote calls inside loops when a batch would work (N+1).
- **GEN-DEP-01 (SHOULD)** Don't add a dependency for something a few lines or the platform already
  handles. Give any new dependency a reason in the plan.
