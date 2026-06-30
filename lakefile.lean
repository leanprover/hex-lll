import Lake
open System Lake DSL

package «hex-lll» where

require HexBasic from git
  "https://github.com/kim-em/hex-basic.git" @ "c9cb6bcb3287ea0870f66c9dfcba08baa08f97f6"
require HexMatrix from git
  "https://github.com/kim-em/hex-matrix.git" @ "d47efb355647c3ab888a035ecfe395be286f2881"
require HexGramSchmidt from git
  "https://github.com/kim-em/hex-gram-schmidt.git" @ "42a1525418b1545ede3c99734e2566be774f0efc"

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
