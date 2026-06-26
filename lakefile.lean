import Lake
open System Lake DSL

package «hex-lll» where

require batteries from git
  "https://github.com/leanprover-community/batteries.git" @ "v4.30.0-rc2"
require HexMatrix from git
  "https://github.com/kim-em/hex-matrix.git" @ "9e3d029b1d95426d04b132b37ff3a1f1790f6e25"
require HexGramSchmidt from git
  "https://github.com/kim-em/hex-gram-schmidt.git" @ "ee2a2896077eff44852e3e8a28e17d2208376e7a"

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
