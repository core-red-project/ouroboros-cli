# Task runner configuration

set windows-shell := ["bash", "-cu"]

default:
    @just --list

# Check the interpreter is present and install the git hooks
install:
    @command -v obfusku >/dev/null || { echo "obfusku is missing: https://github.com/core-red-project/obfusku#installation" >&2; exit 1; }
    git config core.hooksPath .githooks

# Run the CLI from source: just dev -- factorial 30
dev *ARGS:
    obfusku run . -- {{ARGS}}

# Write the standalone executable ./ouroboros
build:
    obfusku bundle . -o ouroboros

# Copy ./ouroboros to ~/.local/bin (or $PREFIX/bin)
install-bin: build
    mkdir -p "${PREFIX:-$HOME/.local}/bin"
    install -m 755 ouroboros "${PREFIX:-$HOME/.local}/bin/ouroboros"

# Run the test files under tests/
test:
    obfusku test .

# Type-check every module of the Project
typecheck:
    obfusku check .

# Fail on any warning (an unreachable arm, an unused pattern…)
lint:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in $(find src tests -name '*.obk' | sort); do
        if obfusku check "$f" 2>&1 >/dev/null | grep -q '^warning:'; then
            echo "warning in $f" >&2; obfusku check "$f" >&2; exit 1
        fi
    done

# Rewrite every source in canonical form (comments are kept)
format:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in $(find src tests -name '*.obk' | sort); do
        obfusku fmt --write "$f"
    done

# Fail when a source is not in canonical form
format-check:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in $(find src tests -name '*.obk' | sort); do
        obfusku fmt --check "$f" || { echo "not formatted: $f (run 'just format')" >&2; exit 1; }
    done

# The command-line contract end to end: exit status, streams, --json
smoke:
    bash scripts/smoke.sh

# The full quality gate (non-mutating)
check: format-check typecheck lint test smoke

# Remove the built executable
clean:
    rm -f ouroboros ouroboros.exe

# Timings: startup and a recursion-heavy command (not part of check)
bench: build
    @command -v hyperfine >/dev/null || { echo "hyperfine is missing: cargo install hyperfine --locked" >&2; exit 1; }
    hyperfine --warmup 2 './ouroboros --version' './ouroboros factorial 1000' './ouroboros factorial 5000' './ouroboros fibonacci 5000' './ouroboros hanoi 18' './ouroboros eval examples/fibonacci.tree'
