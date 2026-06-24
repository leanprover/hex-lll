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

Development happens in [`hex-dev`](https://github.com/kim-em/hex-dev).
