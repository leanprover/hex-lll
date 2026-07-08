import Lake
open System Lake DSL

package «hex-lll» where

require HexBasic from git
  "https://github.com/leanprover/hex-basic.git" @ "f1580d28c2e9ff9e8d4d7cdef9dccbaa17780b03"
require HexMatrix from git
  "https://github.com/leanprover/hex-matrix.git" @ "d45bf749d6283726b8df43b5be9e6dde350666d6"
require HexGramSchmidt from git
  "https://github.com/leanprover/hex-gram-schmidt.git" @ "6bae0c6ed6c19c44956dc69eb31487fc3596f01d"

private def hexlllProviderOTarget (pkg : Package) : FetchM (Job FilePath) := do
  let oFile := pkg.dir / defaultBuildDir / "HexLLL" / "ffi" / "lean_hexlll_provider.o"
  let srcTarget ← inputTextFile <| pkg.dir / "HexLLL" / "ffi" / "lean_hexlll_provider.c"
  buildFileAfterDep oFile srcTarget fun srcFile => do
    let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC"]
    compileO oFile srcFile flags

extern_lib hexlllffi (pkg) := do
  let name := nameToStaticLib "hexlllffi"
  let oTarget ← hexlllProviderOTarget pkg
  buildStaticLib (pkg.staticLibDir / name) #[oTarget]

@[default_target]
lean_lib HexLLL where
  extraDepTargets := #[`hexlllffi]
  moreLinkArgs :=
    if System.Platform.isOSX then
      #[]
    else
      #["-ldl"]

lean_exe hexlll_provider_probe where
  root := `HexLLL.ProviderProbe
