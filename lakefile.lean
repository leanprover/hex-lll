import Lake
open System Lake DSL

package «hex-lll» where

require batteries from git
  "https://github.com/leanprover-community/batteries.git" @ "v4.30.0-rc2"
require HexMatrix from git
  "https://github.com/kim-em/hex-matrix.git" @ "85c2bb9b2f93677fe1435d898c81a56b9e7b33e8"
require HexGramSchmidt from git
  "https://github.com/kim-em/hex-gram-schmidt.git" @ "3ce6d453934ca1bb5eb84ebd5e09b43e3d8ae4ce"

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
