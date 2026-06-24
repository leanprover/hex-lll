#!/usr/bin/env bash
# Conformance oracle runner for `hex-lll`.
#
# Single-library version of the monorepo's sequential oracle runner: this
# repo released only HexLLL, so there is exactly one (lib, emit, oracle,
# fixture) tuple. The step
#
#   1. emits a fresh fixture stream from Lean (`hexlll_emit_fixtures`),
#   2. cross-checks the committed fixture against the fresh emission, and
#   3. pipes the fresh emission into the fpylll oracle for verification.
#
# fpylll (and its FLINT HNF backend, python-flint) are installed once at the
# top of `.github/workflows/ci.yml`; this script assumes they are present.
#
# Exits non-zero on any divergence, with a clear marker.

set -uo pipefail

fresh="/tmp/HexLLL-fresh.jsonl"

echo "=========================================================="
echo ">>> HexLLL :: emit=hexlll_emit_fixtures oracle=scripts/oracle/lll_fpylll.py"
echo "=========================================================="

if ! (cd conformance && lake exe hexlll_emit_fixtures) >"$fresh"; then
  echo "FAIL: HexLLL :: lake exe hexlll_emit_fixtures exited non-zero" >&2
  exit 1
fi

if ! diff -u conformance-fixtures/HexLLL/lll.jsonl "$fresh"; then
  echo "FAIL: HexLLL :: fresh emission diverges from committed fixture" >&2
  exit 1
fi

if ! python3 scripts/oracle/lll_fpylll.py <"$fresh"; then
  echo "FAIL: HexLLL :: oracle scripts/oracle/lll_fpylll.py reported a divergence" >&2
  exit 1
fi

echo
echo "Conformance: HexLLL oracle passed."
