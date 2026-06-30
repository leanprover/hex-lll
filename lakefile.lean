import Lake
open System Lake DSL

package «hex-lll» where

require HexBasic from git
  "https://github.com/kim-em/hex-basic.git" @ "49d4eb822ce66aa14b18c2472c18848a2411792d"
require HexMatrix from git
  "https://github.com/kim-em/hex-matrix.git" @ "a84b3d2bd4186eaebcabbffe0f8bae32b752eccb"
require HexGramSchmidt from git
  "https://github.com/kim-em/hex-gram-schmidt.git" @ "4fd416d0ee1ad4b0bd002dcd75774a91e04c2355"

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
