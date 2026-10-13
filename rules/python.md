# Python defaults (PY)

Loaded when the task touches `.py` files. They override `general.md` where they overlap, and the
project's `CODING_RULES.md` overrides them.

- **PY-FMT-01 (MUST)** Follow PEP 8 through the project's formatter and linter (ruff or black),
  with no new warnings.
- **PY-TYPE-01 (SHOULD)** Add type hints to public functions, and run mypy or pyright if the project
  uses one.
- **PY-EXC-01 (MUST)** No bare `except:` and no `except Exception: pass`. Catch specific exceptions.
- **PY-MUT-01 (MUST)** No mutable default arguments (`def f(x=[])`).
- **PY-RES-01 (MUST)** Use `with` for files, locks and connections, and open text files with an
  explicit `encoding="utf-8"`. *Why:* the platform default (cp1252 on Windows) has corrupted files.
- **PY-PATH-01 (SHOULD)** Use `pathlib` rather than string juggling with `os.path`.
- **PY-SEC-01 (MUST)** No `eval`, `exec` or `pickle` on untrusted input. Call `subprocess` with
  argument lists, never `shell=True` with user input.
- **PY-ENV-01 (SHOULD)** Declare and pin dependencies with the project's mechanism (pyproject or
  requirements plus a lock), and use a virtual environment. Never install globally.
- **PY-LOG-01 (SHOULD)** Application code uses `logging` with lazy arguments
  (`log.info("x %s", y)`), not `print`.
- **PY-TEST-01 (SHOULD)** Use pytest, prefer fixtures over duplicated setup, and use `parametrize`
  for case tables.
- **PY-MAIN-01 (SHOULD)** Scripts use an `if __name__ == "__main__":` guard and avoid module-level
  side effects.
