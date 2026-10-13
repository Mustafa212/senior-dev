# C# / .NET defaults (CS)

Loaded when the task touches `.cs` files. They override `general.md` where they overlap, and the
project's `CODING_RULES.md` overrides them.

## Naming and style
- **CS-NAME-01 (MUST)** Use PascalCase for types, methods, properties and constants, camelCase for
  locals and parameters, and `_camelCase` for private fields. Prefix interfaces with `I`.
- **CS-NAME-02 (SHOULD)** Give async methods the `Async` suffix, following the convention of the
  surrounding code. Names fixed by a framework or interface (for example MediatR `Handle`) are
  exempt.
- **CS-NULL-01 (SHOULD)** In projects that enable nullable reference types, respect them, and
  don't use `!` to silence a warning without a stated invariant.
- **CS-COLL-01 (SHOULD)** Return empty collections, never `null`.

## Async
- **CS-ASYNC-01 (MUST)** Go async all the way: no `.Result`, `.Wait()` or `.GetAwaiter().GetResult()`.
  *Why:* they cause deadlocks and thread-pool starvation.
- **CS-ASYNC-02 (MUST)** No `async void`, except in event handlers.
- **CS-ASYNC-03 (SHOULD)** Accept a `CancellationToken` and pass it through I/O chains (EF Core,
  HttpClient).

## Exceptions and resources
- **CS-EXC-01 (MUST)** Throw specific or project domain exceptions. Rethrow with `throw;`, never
  `throw ex;`, which loses the stack trace. If the project uses `Result<T>`, don't use exceptions
  for expected outcomes.
- **CS-DISP-01 (MUST)** Dispose `IDisposable` and `IAsyncDisposable` with `using` or `await using`.
  Get `HttpClient` from `IHttpClientFactory` and never create one per call.
- **CS-DI-01 (MUST)** Respect DI lifetimes: never inject a scoped service (such as a DbContext) into
  a singleton. No service-locator calls in business code.
- **CS-CONF-01 (SHOULD)** Read configuration through bound `IOptions<T>` classes, not magic string
  keys scattered around the code.

## EF Core and data
- **CS-EF-01 (SHOULD)** Use `AsNoTracking()` for read-only queries, or project to DTOs with
  `Select`.
- **CS-EF-02 (MUST)** Filter, page and project in the database (`IQueryable`) before materializing.
  Never `ToList()` and then `Where`.
- **CS-EF-03 (MUST)** No N+1: use `Include`, a projection or a batched query, not lazy loads inside
  loops.
- **CS-EF-04 (MUST)** Write raw SQL only through parameterized APIs (`FromSql` with interpolation
  or explicit parameters). Never concatenate strings.
- **CS-LINQ-01 (SHOULD)** Use `Any()` rather than `Count() > 0`, and don't enumerate the same
  `IEnumerable` more than once.

## API and layering
- **CS-API-01 (SHOULD)** Keep controllers thin and put business logic in handlers or services.
- **CS-API-02 (MUST)** Validate requests (FluentValidation, or the project's mechanism) before the
  handler runs.
- **CS-DTO-01 (MUST)** Never expose EF entities through the API. Map to DTOs, and use records for
  immutable DTOs.

## Culture, time, logging
- **CS-STR-01 (SHOULD)** Be explicit about culture: use `CultureInfo.InvariantCulture` for machine
  formats and a `StringComparison` for comparisons (CA1305, CA1310).
- **CS-TIME-01 (MUST)** Follow the system's time convention (GEN-DATA-03). In a UTC system, use an
  injected clock (`TimeProvider`, or the project's abstraction), never `DateTime.Now`. In a system
  that stores local time, don't introduce `DateTime.UtcNow`.
- **CS-LOG-01 (SHOULD)** Use structured logging with message templates
  (`LogInformation("Order {OrderId} paid", id)`), not string interpolation.

## Tests
- **CS-TEST-01 (SHOULD)** Name xUnit tests `Method_Scenario_Expected` and structure them as
  Arrange/Act/Assert. Mock the boundaries (HTTP, clock, external services), never the code under
  test.
