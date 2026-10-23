# Moonscript Mode Polish — Plan

Goal: turn `moonscript-mode` into a proper, tested Emacs Lisp package,
fixing packaging hygiene and adding an automated test suite that can
run both locally and in CI with zero external dependencies (ERT is
shipped with Emacs).

## Current state

- Two source files: `moonscript.el` (major mode) and `moonscript-repl.el`
  (comint-based REPL mode).
- No tests, no Makefile, no CI, no Cask file.
- Package headers already declare `Version` and `Package-Requires`
  `((cl-lib "0.5") (emacs "24"))`.
- `moonscript.el` byte-compiles with one warning: missing
  `lexical-binding` directive.
- `.gitignore` only ignores `*.elc`.
- Obsolete `point-at-bol`/`point-at-eol` were already replaced with
  `line-beginning-position`/`line-end-position` in the previous step.

## Scope of work

### 1. Package hygiene (`moonscript.el`, `moonscript-repl.el`)

- Enable `lexical-binding: t` on both files (add the `;;; -*- ... -*-`
  local-variables line / the `lexical-binding` file-local variable).
  The existing top-level `defvar`/`defcustom` definitions are unaffected
  by lexical binding.
- Add standard MELPA header fields currently missing on
  `moonscript.el`: `URL`, `Keywords`, `SPDX-License-Identifier`. Mirror
  on `moonscript-repl.el`.
- Keep `emacs "24"` requirement (ERT-in-Cask target is 24+; lexical
  binding has been supported since 24.1).

### 2. Test suite (`test/moonscript-test.el`)

Use plain ERT (no buttercup dependency). Cover the units that have
real, testable behavior:

- `moonscript-indent-level`
  - Returns 0 for a line at column 0.
  - Returns N for N*`moonscript-indent-offset` leading spaces.
  - Treats a tab as one space (documented behavior).
  - Returns `blankval` for a fully blank line.
  - Errors (via `cl-assert`) when point is not at BOL.
- `moonscript-indent-line`
  - Indents a 0-indent line to `prevlineindent + 1` levels.
  - Cycles one level back on subsequent invocations.
  - Computes "previous non-blank line" across intervening blank lines.
- Font-lock regexes (without relying on a live font-lock run): assert
  that each compiled regex matches the canonical example and that
  `regexp-opt`-produced keyword regex matches all keywords in
  `moonscript-keywords` and rejects a non-keyword.
  - keywords, constants, class names (`Foo`), ivars (`@x`),
    hex numbers (`0xff`), decimal numbers, table keys (`key:`),
    assignment (`=`), assignment var capture group.
- Mode registration
  - `(auto-mode-alist)` maps `".moon"` to `moonscript-mode`.
  - `moonscript-mode` is a derived mode of `prog-mode`.
  - Activating `moonscript-mode` sets `comment-start` to `"-- "`,
    `indent-line-function` to `moonscript-indent-line`, and inhibits
    electric indent.
- Syntax table
  - `--` lines are recognized as comments (`forward-comment` skips a
    `-- foo` line).
  - `_` is a word constituent.
- `moonscript-repl-mode`
  - Derives from `comint-mode`.
  - Shares `moonscript-mode-syntax-table` and font-lock defaults.

Each test uses a fresh `with-temp-buffer` and `moonscript-mode` (or
sets up `indent-line-function` directly) so tests are isolated and
order-independent.

### 3. Build / test automation (`Makefile`)

Targets:
- `test`   — run ERT batch tests.
- `compile` — byte-compile both source files, failing on warnings.
- `check`  — `compile` + `test` (default target).
- `clean`  — remove `*.elc`.
- `elpa`   — build a tarball via `package.el` into `dist/` (nice to
  have; optional, low effort).

Implementation uses `emacs --batch -L . -L test` so no `cask install`
step is required.

### 4. CI (`.github/workflows/test.yml`)

Single matrix job across a few recent Emacs versions available on the
GitHub Actions runner images (29, 30, snapshot). Steps: checkout,
install emacs (via `purcell/setup-emacs` action, common in the Emacs
community), `make check`.

### 5. Repository hygiene

- Expand `.gitignore` to ignore `dist/` and any `*~`/`.#*` backup
  files in addition to `*.elc`.
- Add a `CONTRIBUTING`/Development section to `README.md` describing
  `make test` / `make compile` and how to run a single ERT test.

## Non-goals

- Rewriting the indentation engine (only testing existing behavior).
- Adding new features to the mode itself.
- Migrating to buttercup (ERT keeps the dependency surface at zero).
- MELPA recipe changes (recipe lives in the `melpa` repo).

## Order of execution

1. Add `lexical-binding` + header fields to both `.el` files.
2. Write `test/moonscript-test.el`.
3. Write `Makefile`.
4. Run `make check` locally and fix any failures.
5. Add `.github/workflows/test.yml`.
6. Update `.gitignore` and `README.md`.
7. Commit.