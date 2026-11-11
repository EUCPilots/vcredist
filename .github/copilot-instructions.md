# Copilot instructions

VcRedist is a PowerShell module (`VcRedist/`) that downloads, installs, uninstalls and packages Microsoft Visual C++ Redistributables (MDT, ConfigMgr, Intune). Supports Windows PowerShell 5.1 and PowerShell 7+; keep code compatible with both.

## Build, test, lint

There is no build step. Tests are Pester and are designed for Windows (the real tests download and install redistributables; CI runs on `windows-2025` and `windows-11-arm`).

```powershell
# Import the module from source
Import-Module ./VcRedist/VcRedist.psd1 -Force     # or ./Import.ps1

# Install/upgrade Pester
./tests/Install-Pester.ps1

# Full suite (CI also enables code coverage on ./VcRedist)
Invoke-Pester -Path ./tests

# Single test file / single test by name
Invoke-Pester -Path ./tests/Public/Get-VcList.Tests.ps1
Invoke-Pester -Path ./tests/Public/Get-VcList.Tests.ps1 -FullNameFilter "*2022*"

# Lint (same as CI analyzer workflow; includes custom rules in .rules/)
Invoke-ScriptAnalyzer -Path ./VcRedist -Recurse -Settings ./.rules/PSScriptAnalyzerSettings.psd1
```

Tests import the module themselves via `BeforeDiscovery`/`BeforeAll`, so import it first. Test layout mirrors source: `tests/Public/<Function>.Tests.ps1`, `tests/Private/<Function>.Tests.ps1`, plus `Manifest.Tests.ps1` and `Module.Tests.ps1`. Disabled tests are renamed to `*.Tests.ps1.txt`. Intune tests need `TENANT_ID`/`CLIENT_ID`/`CLIENT_SECRET` env vars; MDT and ConfigMgr tests use stubbed/mocked cmdlets and need no installed product.

## Architecture

- `VcRedist/VcRedist.psm1` dot-sources every `Public/*.ps1` and `Private/*.ps1`, and exports **only** the file basenames from `Public/` (one function per file, filename = function name).
- **`VcRedist/VisualCRedistributables.json` is the data source** for everything: a flat `{ SchemaVersion, Updated, Entries[] }` where each entry has a `Supported` boolean (Name, ProductCode, Version, URI, Release, Architecture, Install/SilentInstall/SilentUninstall args, UninstallKey, PackageId, DetectionFile). `Private/Get-VcManifest` resolves it (remote `v5`/`main` raw URL first, bundled copy as fallback; `-Source Auto|Remote|Bundled`) and `Get-VcList` emits objects that flow down a pipeline: `Get-VcList | Save-VcRedist -Path … | Install-VcRedist` / `Import-Vc*Application` / `New-VcMdtBundle`. Downstream functions validate input with `Private/Test-VcListObject`.
- `VcRedist/VcRedist.json` holds static module config (uninstall registry keys, filters, `#ProductCode`/`#Installer` placeholder tokens, URLs); `Intune.json` holds Intune app config.
- `Private/` holds helpers (`Invoke-Process`, `Get-InstalledSoftware`, MDT drive/module helpers, Intune detection rules/queries).
- `VcRedist/en-US/` contains help (`VcRedist-help.xml`, `about_VcRedist.help.txt`); `scripts/Update-Help.ps1` regenerates help.

## CI / release

- `ci/Update-Manifest.ps1` (run by `update-manifest.yml` nightly on Windows) installs each release, compares installed versions with the manifest and updates `VisualCRedistributables.json` on the `manifest-update` branch via PR. Don't hand-edit versions/URIs unless fixing the manifest; `Manifest.Tests.ps1` validates it.
- `validate-module.yml` bumps `ModuleVersion` in `VcRedist.psd1` automatically (`Step-ModuleVersion -By Build`); don't bump it manually.
- Pull requests go to `main`; PRs should follow `.github/PULL_REQUEST_TEMPLATE.md`.

## Conventions

- Use lowercase PowerShell keywords (`foreach`, `if`, `function`, `param`) and PascalCase for function/parameter names — enforced by the custom rules in `.rules/LowercaseKeyword.psm1` and `.rules/PascalCase.psm1`.
- Use `[System.String]`-style full type names and double-quoted string arguments for attribute/parameter values (e.g. `-ErrorAction "SilentlyContinue"`, `[ValidateSet("Supported", "All")]`).
- Suppress analyzer rules with `[Diagnostics.CodeAnalysis.SuppressMessageAttribute(...)]` including a `Justification`.
- Functions use comment-based help (`.SYNOPSIS`, `.PARAMETER`, `.EXAMPLE`); update it (and the help in `en-US/`) when changing parameters.
- Releases are identified by string (`"2015"`, `"2022"`, `"14"`); the "14" release covers the unified 2015–2022+ runtime, with arm64 handled as a special case in `Update-Manifest.ps1`.
- Indentation: 4 spaces.
