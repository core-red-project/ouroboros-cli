# Ouroboros

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/License-MIT-green)
[![CI](https://github.com/core-red-project/ouroboros-cli/workflows/CI/badge.svg)](https://github.com/core-red-project/ouroboros-cli/actions)

<p align="center">
  <strong>Recursion as the subject ✦ Integers of any size ✦ One standalone binary</strong><br>
  <em>A command-line tool written in Obfusku: factorials, Fibonacci, Towers of Hanoi and a tree-language evaluator, all by recursion.</em>
</p>

<p align="center">
  <a href="#about">About</a> ✦
  <a href="#features">Features</a> ✦
  <a href="#installation">Installation</a> ✦
  <a href="#usage">Usage</a> ✦
  <a href="#architecture">Architecture</a> ✦
  <a href="#contributing">Contributing</a>
</p>

---

## About

**Ouroboros** is a recursive command-line tool written in [Obfusku](https://github.com/core-red-project/obfusku): integers of any size, Towers of Hanoi, and an evaluator for a small tree language.

It exists to show that Obfusku builds something that works outside a toy — arguments, input and output, errors with exit codes, data structures, modules and tests — with recursion as the subject, not just the tool.

Natural numbers are lists of base-10⁹ limbs; signed integers, division and the evaluator are built on them. The program bundles into a single executable that needs no interpreter on the machine.

### Philosophy

> _"No hay nada más experimental que la recursión."_

This is a Core Red project, part of the Sxnnyside Project's experimental branch.

## Features

- **Integers of any size**: `factorial 5000`, `fibonacci 20000`, signed, with truncating division and Karatsuba multiplication ($O(N^{\log_2 3})$).
- **Towers of Hanoi**: every move of up to 20 disks, or 2^N − 1 as a number for up to 20000.
- **Tree evaluator**: `def`, `let`, `if`, arithmetic, comparison and calls over a small s-expression format, powered by persistent balanced AVL trees ($O(\log N)$ lookup).
- **Scriptable**: `--json` on every command, `-q`/`-v`, `NO_COLOR`, exit codes 0, 1 and 2.
- **Shell completions**: `bash`, `zsh`, `fish` and `powershell`.
- **Standalone binary**: Linux x86_64, macOS arm64, Windows x86_64.
- **Declared capabilities**: the manifest states exactly what the program may touch.

## Installation

### Prerequisites

- [Obfusku](https://github.com/core-red-project/obfusku#installation) (≥ 1.1) — only to build from source

### Binary

Linux x86_64 and macOS arm64, no `obfusku` needed:

```bash
curl -fsSL https://raw.githubusercontent.com/core-red-project/ouroboros-cli/main/install.sh | bash
ouroboros --help
```

It lands in `~/.local/bin`; put that on your `PATH`.

### From Source

```bash
git clone https://github.com/core-red-project/ouroboros-cli.git
cd ouroboros-cli

just build        # writes ./ouroboros, a standalone executable
just install-bin  # copies it to ~/.local/bin
```

Or run from source without building: `obfusku run . -- factorial 30`.

## Usage

```console
$ ouroboros factorial 30
265252859812191058636308480000000
$ ouroboros fibonacci 200
280571172992510140037611932413038677189525
$ ouroboros hanoi 3
move disk 1 from A to C
move disk 2 from A to B
move disk 1 from C to B
move disk 3 from A to C
move disk 1 from B to A
move disk 2 from B to C
move disk 1 from A to C
$ ouroboros hanoi 64 --count
18446744073709551615
$ ouroboros eval examples/integers.tree
-14
-2
-12193263113702179522496570642237463801111263526900
-9223372036854775808
$ ouroboros tree examples/shape.tree --json
{"command":"tree","forms":1,"nodes":7,"leaves":25,"depth":3,"outline":[…]}
```

## Commands

| Command             | What it does                                                                 |
| ------------------- | ---------------------------------------------------------------------------- |
| `factorial N`       | N! as an integer of any size (N ≤ 5000)                                      |
| `fibonacci N`       | the Nth Fibonacci number (N ≤ 20000)                                         |
| `hanoi N [--count]` | the moves of an N-disk tower (N ≤ 20), or 2^N − 1 with `--count` (N ≤ 20000) |
| `eval FILE`         | evaluate a tree program; `-` reads standard input                            |
| `tree FILE`         | outline a tree and report forms, nodes, leaves and depth                     |
| `completions SHELL` | completion script for `bash`, `zsh`, `fish` or `powershell`                  |
| `help`, `version`   | also `-h`/`--help`, `-V`/`--version`                                         |

Global options, before or after the command:

| Option            | Effect                                                                          |
| ----------------- | ------------------------------------------------------------------------------- |
| `-q`, `--quiet`   | print nothing but errors                                                        |
| `-v`, `--verbose` | explain what is being done, on standard error                                   |
| `--json`          | one JSON object on standard output                                              |
| `--no-color`      | no color (also `NO_COLOR`; color is off when standard output is not a terminal) |

An unknown command suggests the closest one: `ouroboros fctorial 5` → `did you mean 'factorial'?`.

## Output & exit codes

Standard output carries data only; diagnostics, progress and errors go to standard error as
`error: <what happened>` followed by a line saying what to do.

| Status | Meaning                                                             |
| ------ | ------------------------------------------------------------------- |
| `0`    | success                                                             |
| `1`    | failure: a syntax or evaluation error in a tree, an unreadable file |
| `2`    | usage error: bad arguments, an unknown command or option            |

### `--json` keys

| Command                  | Object                                                                    |
| ------------------------ | ------------------------------------------------------------------------- |
| `factorial`, `fibonacci` | `{"command", "n", "value"}` — `value` is a decimal string                 |
| `hanoi N`                | `{"command", "n", "moves":[{"disk","from","to"}, …]}`                     |
| `hanoi N --count`        | `{"command", "n", "moves"}` — `moves` is a decimal string                 |
| `eval`                   | `{"command", "results":[string, …]}`                                      |
| `tree`                   | `{"command", "forms", "nodes", "leaves", "depth", "outline":[string, …]}` |

### The tree format

```
; comment to end of line
(def fact (n)
  (if (eq n 0) 1 (mul n (fact (sub n 1)))))
(fact 30)
```

Forms: `(def name (params…) body)`, `(let name value body)`, `(if cond then else)` (0 is false),
`(add a b)`, `(sub a b)`, `(mul a b)`, `(div a b)`, `(mod a b)`, `(pow a n)`, `(neg a)`, `(abs a)`,
`(eq a b)`, `(lt a b)` and calls `(name args…)`. Numbers are signed integers of any size; division
truncates toward zero and the remainder takes the dividend's sign. Calls nest at most 10000 deep, so
`(def f (n) (f n)) (f 1)` ends with an error instead of running forever (the host gives tail calls for free).

## What happens at the edges

| Input                                 | Result                                                             |
| ------------------------------------- | ------------------------------------------------------------------ |
| `factorial 999999999999999`           | `error: N is limited to 5000`, exit 2                              |
| `factorial -1`, `factorial x`         | usage error, exit 2                                                |
| `hanoi 30`                            | refuses to print 2^30 moves; `--count` gives the number            |
| `(div 1 0)`                           | `error: division by zero`, exit 1                                  |
| unbounded recursion in a tree program | cut off at 10000 calls, exit 1                                     |
| deep recursion inside Obfusku itself  | the host's recursion limit raises a catchable error, never a crash |

## Configuration

None: no configuration file, no environment variable except `NO_COLOR`. `obfusku.toml` declares exactly
what the program may use — console, arguments, `NO_COLOR`, exit, and the working directory for `eval FILE`
and `tree FILE` (paths outside it are refused).

## Architecture

```
ouroboros-cli/
├── src/        # Obfusku modules: main, cli, json, bigint, integer, hanoi, sexpr, evaluator
├── tests/      # one *_test.obk per module, run by `obfusku test`
├── examples/   # tree programs: factorial, fibonacci, ackermann, shape, integers
├── scripts/    # smoke.sh and commit-message checks
└── docs/       # benchmarks.md
```

```bash
just dev -- factorial 30   # run from source
just test                  # obfusku test: tests/*_test.obk
just smoke                 # exit status, streams and --json, end to end
just check                 # the full gate
just bench                 # timings, see docs/benchmarks.md
```

Baselines and method: [docs/benchmarks.md](docs/benchmarks.md).

### Algorithmic Highlights

- **Multiplicación de BigInts (Karatsuba)**: Implementada en pura recursión sobre listas de extremidades en base $10^9$. Conmuta automáticamente de multiplicación escolar $O(N \cdot M)$ a Karatsuba ($O(N^{\log_2 3}) \approx O(N^{1.585})$) al superar el umbral de extremidades, descomponiendo operandos en mitades y reduciendo 4 multiplicaciones a 3.
- **Estructuras balanceadas (Persistent AVL Trees)**: Los entornos de variables y funciones en el evaluador utilizan árboles de búsqueda binaria persistentes balanceados por altura (AVL). Reemplaza la búsqueda lineal $O(N)$ por acceso y enlace en $O(\log N)$, preservando la inmutabilidad y compartiendo subárboles en ámbitos léxicos (`let` y parámetros).

## Contributing

Contributions are accepted. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Before contributing, read the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <strong>Ouroboros</strong> — A Core Red Project<br>
  <em>&copy; 2026 Sxnnyside Project</em>
</p>
