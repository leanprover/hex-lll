import Lake
open System Lake DSL

package «hex-lll» where

require HexBasic from git
  "https://github.com/leanprover/hex-basic.git" @ "f1580d28c2e9ff9e8d4d7cdef9dccbaa17780b03"
require HexMatrix from git
  "https://github.com/leanprover/hex-matrix.git" @ "db6b7f7aebf6d1fb193016cbc5b21214bf40ab68"
require HexGramSchmidt from git
  "https://github.com/leanprover/hex-gram-schmidt.git" @ "f5ba63bd84e4086b714375bf3600e4d8cbc67987"

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
