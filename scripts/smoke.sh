#!/usr/bin/env bash
# End-to-end checks of the command-line contract: exit status, which
# stream carries what, and the shape of --json. Needs `obfusku` on PATH.
set -uo pipefail

fail=0
errfile="$(mktemp)"
trap 'rm -f "$errfile"' EXIT
run() { obfusku run . -- "$@"; }

# expect <what> <exit> <stdout has> <stderr has> -- args…
expect() {
  local what="$1" want="$2" out_has="$3" err_has="$4"
  shift 5
  local out err code
  out="$(run "$@" 2>"$errfile")"; code=$?
  err="$(cat "$errfile")"
  if [ "$code" -ne "$want" ]; then
    echo "FAIL $what: exit $code, wanted $want"; fail=1; return
  fi
  if [ -n "$out_has" ] && [[ "$out" != *"$out_has"* ]]; then
    echo "FAIL $what: stdout lacks '$out_has': $out"; fail=1; return
  fi
  if [ -n "$err_has" ] && [[ "$err" != *"$err_has"* ]]; then
    echo "FAIL $what: stderr lacks '$err_has': $err"; fail=1; return
  fi
  echo "ok   $what"
}

expect "version"               0 "ouroboros 0.1.0" ""             -- --version
expect "version after command" 0 "ouroboros 0.1.0" ""             -- factorial 5 -V
expect "help"                  0 "USAGE"           ""             -- --help
expect "factorial"             0 "2432902008176640000" ""         -- factorial 20
expect "factorial json"        0 '"value":"2432902008176640000"' "" -- factorial 20 --json
expect "quiet prints nothing"  0 ""                ""             -- factorial 20 -q
expect "verbose on stderr"     0 "2432902008176640000" "verbose:" -- factorial 20 -v
expect "hanoi count"           0 "18446744073709551615" ""        -- hanoi 64 --count
expect "eval"                  0 "120"             ""             -- eval examples/factorial.tree
expect "signed division"       0 "-14"             ""             -- eval examples/integers.tree
expect "unknown command"       2 ""                "did you mean 'factorial'" -- fctorial 5
expect "missing argument"      2 ""                "--help"       -- factorial
expect "negative count"        2 ""                "must not be negative" -- factorial -5
expect "bad tree"              1 ""                "error:"       -- eval examples/broken.tree
expect "completions"           0 "complete"        ""             -- completions bash
expect "completions bad shell" 2 ""                "unsupported shell" -- completions tcsh

# stdout stays clean on failure
out="$(run eval examples/broken.tree 2>/dev/null)"
if [ -n "$out" ]; then echo "FAIL stdout not empty on error: $out"; fail=1; else echo "ok   stdout empty on error"; fi

# --json is one parseable object
if command -v python3 >/dev/null; then
  if run tree examples/shape.tree --json | python3 -c 'import json,sys; d=json.load(sys.stdin); assert d["command"]=="tree" and d["nodes"]>0'; then
    echo "ok   tree --json parses"
  else
    echo "FAIL tree --json"; fail=1
  fi
fi

exit $fail
