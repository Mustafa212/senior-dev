# Flutter / Dart defaults (DART)

Loaded when the task touches `.dart` files. They override `general.md` where they overlap, and the
project's `CODING_RULES.md` overrides them.

## Language
- **DART-LINT-01 (MUST)** The code passes `flutter analyze` with the project's
  `analysis_options.yaml` and is formatted with `dart format`.
- **DART-NAME-01 (MUST)** Follow Effective Dart naming: `UpperCamelCase` for types,
  `lowerCamelCase` for members, variables and constants, `snake_case` for files, and `_` as the
  private prefix.
- **DART-NULL-01 (MUST)** Keep null safety sound. Avoid `!` unless the invariant is proven, and
  prefer `?.`, `??` and early returns.
- **DART-ASYNC-01 (MUST)** Await futures, or wrap them explicitly in `unawaited()`. No silent fire
  and forget.

## Widgets and state
- **DART-CONST-01 (SHOULD)** Use `const` constructors and widgets wherever possible.
- **DART-WIDGET-01 (SHOULD)** Split large `build` methods into small widget classes, not helper
  methods that return widgets, so they rebuild efficiently and read clearly.
- **DART-STATE-01 (MUST)** Use one state-management approach per project (Bloc, Riverpod or
  Provider, whichever the project uses). Keep business logic and API calls out of widgets.
- **DART-CTX-01 (MUST)** Check `context.mounted` (or `mounted`) before using a `BuildContext` after
  an `await`.
- **DART-DISPOSE-01 (MUST)** Dispose controllers (text, animation, scroll) and cancel stream
  subscriptions in `dispose()`.
- **DART-ARCH-01 (SHOULD)** Layer the app as UI → state → repository → data source, and keep models
  immutable (final fields with `copyWith`, or freezed/equatable).

## UI
- **DART-UI-01 (SHOULD)** No hard-coded user-facing strings (use the project's localization) and
  no hard-coded colors or sizes (use the `Theme`).
- **DART-UI-02 (SHOULD)** Support RTL and text scaling with `EdgeInsetsDirectional` and
  `AlignmentDirectional`.
- **DART-UI-03 (MUST)** Every async screen shows loading, error and empty states, not a silent
  failure.
- **DART-PERF-01 (SHOULD)** Use `ListView.builder` for long lists and keep heavy work out of
  `build()`.

## Tests
- **DART-TEST-01 (SHOULD)** Write unit tests for state and logic and widget tests for key screens,
  with mocked repositories.
