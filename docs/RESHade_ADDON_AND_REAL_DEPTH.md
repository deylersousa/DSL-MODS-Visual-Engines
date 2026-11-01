# ReShade Add-on Support and depth behavior

## Installed by DSL MODS Visual Engine Setup

The Windows installer downloads the official `ReShade_Setup_<version>_Addon.exe` from `reshade.me`, checks the expected installer integrity, and runs it headlessly with `--api dxgi` targeting a temporary copy of the **DSL MODS host** (`Unishade.exe`). It collects the resulting **`dxgi.dll`** into the DSL application installation. This is the official **ReShade Add-on Support** edition.

The DLL lives next to `Unishade.exe`, not next to an arbitrary game's executable. DSL MODS is an **external game-window capture host**; this procedure does not install a native depth-capable ReShade DLL into a game. Do not copy it to games automatically or imply it can access their native depth buffers.

## Synthetic depth is not installed

The legacy **Depth estimation** option was removed from the setup UI and rejected by the silent installer (`--components reshade,depth` is invalid). The optional add-on does not download the `depth-anything-v2-small.onnx` model, ONNX Runtime or DirectML estimation libraries. During an upgrade with ReShade selected, previously installed depth-estimation files are removed by the existing add-on cleanup path.

**Depth-buffer effects** such as MXAO, SSR and RTGI require genuine depth information provided by a compatible runtime. Screen capture cannot provide the game's depth buffer. ReShade add-on support on the external host does **not** grant access to the original game's depth buffer. Results remain game-dependent; no synthetic substitute is silently injected.

## Compatibility

- DirectX 11 / DXGI applies to the DSL host setup.
- ReShade Add-on Support is separate from using third-party add-ons; individual add-ons may have their own hardware, legal and compatibility constraints.
- Native ReShade installation into a game would be a different opt-in workflow and must check game compatibility, anti-cheat rules, existing `dxgi.dll` conflicts and backups before making changes.
- Installation requires internet access to the official ReShade distribution source and user acceptance of the ReShade license.

## Validation

Check the Windows installer test suite for `dxgi.dll` presence, `depth-anything-v2-small.onnx` absence and rejection of the old `depth` component. Test effects requiring actual game depth only on a compatible native runtime and never represent external depth capture as a real depth buffer.
