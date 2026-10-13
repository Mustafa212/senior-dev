# TypeScript / Angular defaults (TS, NG)

Loaded when the task touches `.ts` or Angular template files. They override `general.md` where they
overlap, and the project's `CODING_RULES.md` overrides them.

## TypeScript
- **TS-STRICT-01 (MUST)** Use strict mode and no `any`. Use `unknown` with narrowing instead, and
  don't use non-null `!` without a stated invariant.
- **TS-TYPE-01 (SHOULD)** Type API responses with interfaces that match the backend DTOs.
- **TS-EQ-01 (MUST)** Use `===` and `!==`.
- **TS-IMMUT-01 (SHOULD)** Use `const` by default and `readonly` for fields that are never
  reassigned. Don't mutate inputs or state in place.
- **TS-ASYNC-01 (MUST)** Await or handle every Promise. No floating promises.

## Angular
- **NG-IDIOM-01 (MUST)** Use the idioms of the project's Angular version consistently (standalone
  components, signals, `@if`/`@for` from v17 on). Don't mix old and new styles inside one feature
  unless the project already does.
- **NG-RX-01 (MUST)** Don't leak subscriptions. Long-lived streams (form `valueChanges`, router
  events, store selectors, intervals, websockets) are torn down with the `async` pipe, `toSignal`
  or `takeUntilDestroyed`. A one-shot observable that completes on its own (an `HttpClient` call)
  doesn't need teardown.
- **NG-RX-02 (SHOULD)** No nested `subscribe`. Compose with operators (`switchMap`, `combineLatest`).
- **NG-CD-01 (SHOULD)** Use `OnPush` change detection (or signals) for new components.
- **NG-COMP-01 (SHOULD)** Components never call `HttpClient` directly; go through services. Keep
  container (smart) and presentational components separate.
- **NG-TPL-01 (SHOULD)** No method calls in templates, except signal reads. Use pipes or `computed`.
- **NG-FOR-01 (MUST)** Lists need `track` in `@for` (or `trackBy` in `*ngFor`).
- **NG-SEC-01 (MUST)** Never bypass sanitization (`bypassSecurityTrust*`) or bind `innerHTML` to
  untrusted content.
- **NG-I18N-01 (SHOULD)** In a localized app, put no hard-coded user-facing strings in templates.
  Use the project's i18n mechanism. Styles must be RTL-safe, using logical properties such as
  `margin-inline-start`.
- **NG-FORM-01 (SHOULD)** Use typed reactive forms, and show a message for every validator.
- **NG-HTTP-01 (SHOULD)** Handle errors centrally in an interceptor. Screens handle the loading,
  error and empty states.
- **NG-TEST-01 (SHOULD)** Test components through their public behavior (DOM, inputs, outputs) and
  mock their services.
- **NG-LINT-01 (MUST)** The code passes lint and `ng build` with no new warnings.
