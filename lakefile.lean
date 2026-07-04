import Lake
open System Lake DSL

package «hex-lll» where

require HexBasic from git
  "https://github.com/leanprover/hex-basic.git" @ "f1580d28c2e9ff9e8d4d7cdef9dccbaa17780b03"
require HexMatrix from git
  "https://github.com/leanprover/hex-matrix.git" @ "99706e1ab14f79a915b3fd86ffa37da4a800a0d6"
require HexGramSchmidt from git
  "https://github.com/leanprover/hex-gram-schmidt.git" @ "ebac2cab09a009da396d905d905ebe054532212e"

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
