# Benchmarks

Baselines for `just bench`. Not part of `just check`: timings are noisy.

## 2026-10-15 — Apple M4 Pro, macOS 26.6 (arm64), obfusku release build

Method: the standalone executable from `obfusku bundle . -o ouroboros`, five runs per
command, median wall time (`just bench` runs the same commands under `hyperfine`).

| Command | Median | Notes |
|---|---:|---|
| `ouroboros --version` | 34 ms | startup floor: the interpreter loads and checks every module |
| `ouroboros hanoi 64 --count` | 33 ms | closed form, no enumeration |
| `ouroboros eval examples/factorial.tree` | 36 ms | |
| `ouroboros eval examples/fibonacci.tree` | 103 ms | double recursion, `(fib 15)` |
| `ouroboros factorial 1000` | 90 ms | 2568 digits |
| `ouroboros fibonacci 5000` | 251 ms | 1045 digits |
| `ouroboros hanoi 18` | 396 ms | prints 262 143 moves |
| `ouroboros factorial 5000` | 1824 ms | 16326 digits; the `N ≤ 5000` limit |

A release more than 10 % slower on a row needs a note in `CHANGELOG.md`.
