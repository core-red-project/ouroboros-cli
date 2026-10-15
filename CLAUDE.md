# Ouroboros — CLAUDE.md

A recursive CLI written in Obfusku (`obfusku.toml`, format 2). All logic is in `src/`; there is no host-language code.

## Where things go

| What | Where |
|---|---|
| Dispatch, output modes, exit status | `src/main.obk` |
| Options, help, completions, man page, colors, suggestions | `src/cli.obk` |
| JSON text for `--json` | `src/json.obk` |
| Signed integers and division | `src/integer.obk` |
| Natural numbers of any size | `src/bigint.obk` |
| Hanoi moves and count | `src/hanoi.obk` |
| Tree format: tokens, parser, outline, measures | `src/sexpr.obk` |
| Tree evaluator (`def`, `let`, `if`, arithmetic) | `src/evaluator.obk` |
| List helpers shared by modules | `src/prelude.obk` |
| Tests: one `*_test.obk` per module, helpers in `support.obk` | `tests/` |
| Example tree programs | `examples/*.tree` |

## Commands

`just dev -- <args>` · `just build` · `just test` · `just check` (see the Justfile).

## Rules

- Module names are file stems and must be unique across `src/` and `tests/` (imports are by name, `ADR-018`): tests are `<module>_test.obk`.
- A test passes when its program finishes; an assertion raises `Failure("assertion", …)` (`tests/support.obk`).
- Capabilities live in `obfusku.toml`; add one only when a feature needs it.
- Subtraction is `☠︎` (U+2620 U+FE0E); the variation selector is part of the glyph.
