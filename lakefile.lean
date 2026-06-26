import Lake
open System Lake DSL

package «hex-lll» where

require batteries from git
  "https://github.com/leanprover-community/batteries.git" @ "v4.30.0-rc2"
require HexMatrix from git
  "https://github.com/kim-em/hex-matrix.git" @ "ad566de56bb6aea7fee8b9ec922c19e751df230f"
require HexGramSchmidt from git
  "https://github.com/kim-em/hex-gram-schmidt.git" @ "c02a134d84c68e07a65cff52262f651891a51364"

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
  moreLinkArgs := #[
    s!"{(defaultBuildDir / "lib" / nameToStaticLib "hexlllffi").toString}",
    "-ldl"
  ]

lean_exe hexlll_provider_probe where
  root := `HexLLL.ProviderProbe
