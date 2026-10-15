# Changelog

All notable changes to **Ouroboros** are documented here.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [0.1.0] — 2026-10-15

### Added

- Commands `factorial`, `fibonacci`, `hanoi [--count]`, `eval`, `tree`, `completions`.
- Integers of any size, signed, with truncating division (`div`, `mod`) in the tree language.
- Global options `-q`, `-v`, `--json`, `--no-color` (and `NO_COLOR`), `-h`, `-V`; hidden `man`.
- "Did you mean" for an unknown command; an error always names what to do.
- `just smoke`: exit status, standard streams and `--json` checked end to end.
- Tests for every module (`obfusku test`), and baselines in `docs/benchmarks.md`.

---

[Unreleased]: https://github.com/core-red-project/ouroboros-cli/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/core-red-project/ouroboros-cli/releases/tag/v0.1.0
