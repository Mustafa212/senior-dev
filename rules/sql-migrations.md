# SQL and migrations defaults (SQL)

Loaded when the task touches SQL, schema or migrations. They override `general.md` where they
overlap, and the project's `CODING_RULES.md` overrides them.

## Queries
- **SQL-PARAM-01 (MUST)** Use parameterized queries only.
- **SQL-SEL-01 (MUST)** No `SELECT *` in application queries or views. List the columns.
- **SQL-SARG-01 (SHOULD)** Keep predicates sargable: no functions wrapping indexed columns in
  `WHERE`, and parameter types that match column types (no implicit `nvarchar`/`varchar`
  conversion).
- **SQL-IDX-01 (SHOULD)** Columns used in frequent `WHERE`, `JOIN` or `ORDER BY` clauses have
  supporting indexes, and foreign keys are indexed.
- **SQL-TXN-01 (MUST)** Run multi-statement changes in a transaction with error handling (on SQL
  Server, `SET XACT_ABORT ON`).

## Schema and migrations
- **SQL-MIG-01 (MUST)** Every schema change goes through the project's migration tool. Never
  change a shared database by hand.
- **SQL-MIG-02 (MUST)** Read the generated SQL of every migration before it's applied. Never apply
  a migration to a shared database without the user's explicit OK.
- **SQL-MIG-03 (MUST)** A destructive migration (dropping or renaming a column or table, narrowing a
  type, adding `NOT NULL` without a default) needs explicit approval in the plan, with its data
  impact stated. When the table holds production data that has to survive, use an expand →
  migrate → contract sequence.
- **SQL-MIG-04 (SHOULD)** Manually applied scripts can be re-run safely (`IF NOT EXISTS` guards),
  and every migration has a rollback path.
- **SQL-MIG-05 (SHOULD)** Keep data migrations separate from schema migrations, and batch them on
  large tables.
- **SQL-TYPE-01 (SHOULD)** New columns state `NULL`/`NOT NULL` and their defaults explicitly, and
  use fitting types: `datetime2` for time and `decimal` for money, never `float`.
- **SQL-NAME-01 (SHOULD)** Follow the schema's existing naming for tables and for PK, FK and index
  constraints.
- **SQL-DEL-01 (MUST)** Respect the project's delete semantics. Never hard-delete where the project
  uses soft-delete flags or audit columns.
