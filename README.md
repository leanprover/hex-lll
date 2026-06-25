# hex-lll

LLL lattice reduction for the `hex` project, with an optional FFI provider
(fpLLL). Mathlib-free.

```
require HexLLL from git "https://github.com/kim-em/hex-lll.git" @ "<rev>"
```

- Depends on [`hex-matrix`](https://github.com/kim-em/hex-matrix) and
  [`hex-gram-schmidt`](https://github.com/kim-em/hex-gram-schmidt).
- Mathlib correspondence: [`hex-lll-mathlib`](https://github.com/kim-em/hex-lll-mathlib).
- Benchmarks in [`bench/`](bench); conformance in [`conformance/`](conformance) (own lakefiles).
- C FFI provider shim: [`HexLLL/ffi/`](HexLLL/ffi).
- Spec: [SPEC/hex-lll.md](SPEC/hex-lll.md).

## Optional fpLLL FFI provider

Reduction runs entirely in verified native Lean by default. To accelerate it
with an external reducer (such as fpLLL), plug one in at runtime:

- Set `HEX_FPLLL_FFI_LIB` to the path of a shared library that exports the C
  symbol `lean_fplll_lll_reduce`. The shim `dlopen`s it once per process
  (`RTLD_NOW | RTLD_GLOBAL`); if loading fails it logs to stderr and carries on.
- Every candidate the provider returns is decoded and checked before use; a
  structurally invalid or non-reduced response is rejected.
- If the variable is unset, the library is absent, or a candidate is rejected,
  the verified native reducer runs automatically. Results are always correct —
  the provider is acceleration only, never part of the trusted path, and the
  build needs no fpLLL present.

The C shim lives in [`HexLLL/ffi/`](HexLLL/ffi); see
[SPEC/hex-lll.md](SPEC/hex-lll.md) for the dispatch and certification details.

Development happens in [`hex-dev`](https://github.com/kim-em/hex-dev).
