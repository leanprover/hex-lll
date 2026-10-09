import Lake
open System Lake DSL

package «hex-lll» where
  leanOptions := #[⟨`doc.verso, true⟩, ⟨`doc.verso.suggestions, false⟩]

require HexBasic from git
  "https://github.com/leanprover/hex-basic.git" @ "v0.9.0"
require HexMatrix from git
  "https://github.com/leanprover/hex-matrix.git" @ "v0.9.0"
require HexGramSchmidt from git
  "https://github.com/leanprover/hex-gram-schmidt.git" @ "v0.9.0"

private def hexlllProviderOTarget (pkg : Package) : FetchM (Job FilePath) := do
  let oFile := pkg.dir / defaultBuildDir / "HexLLL" / "ffi" / "lean_hexlll_provider.o"
  let srcTarget ← inputTextFile <| pkg.dir / "HexLLL" / "ffi" / "lean_hexlll_provider.c"
  buildFileAfterDep oFile srcTarget fun srcFile => do
    let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-O3"]
    compileO oFile srcFile flags

extern_lib hexlllffi (pkg) := do
  let name := nameToStaticLib "hexlllffi"
  let oTarget ← hexlllProviderOTarget pkg
  buildStaticLib (pkg.staticLibDir / name) #[oTarget]

@[default_target]
lean_lib HexLLL where
  precompileModules := true
  extraDepTargets := #[`hexlllffi]
  -- `dlopen` lives in libdl on Linux, in libc on macOS, and is absent on
  -- Windows, where the provider uses LoadLibrary instead.
  moreLinkArgs :=
    if System.Platform.isOSX || System.Platform.isWindows then
      #[]
    else
      #["-ldl"]

lean_exe hexlll_external_reduction where
  root := `HexLLL.ExternalReduction
