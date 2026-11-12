<#
    .SYNOPSIS
        Tests release preparation and publishing without network access.
#>
[CmdletBinding()]
param ()

BeforeAll {
    $Repository = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $MetadataScript = Join-Path $Repository "ci/Get-ReleaseMetadata.ps1"
    $UpdateScript = Join-Path $Repository "ci/Update-Release.ps1"
    $PublishScript = Join-Path $Repository "ci/Publish-Release.ps1"
    $DocumentScript = Join-Path $Repository "ci/New-VcVersionsDocument.ps1"
    & (Join-Path $Repository "ci/Install-Analyzer.ps1")
    Add-Type -AssemblyName "System.IO.Compression"
    if (-not ("ReleaseHttpException" -as [System.Type])) {
        Add-Type -TypeDefinition @"
public class ReleaseHttpResponse { public int StatusCode; }
public class ReleaseHttpException : System.Exception {
    public ReleaseHttpResponse Response;
    public ReleaseHttpException(int status) : base("Test HTTP failure") {
        Response = new ReleaseHttpResponse { StatusCode = status };
    }
}
"@
    }

    function New-ReleaseFixture {
        $Root = Join-Path $TestDrive ([System.Guid]::NewGuid().ToString())
        New-Item -Path "$Root/VcRedist/Public", "$Root/docs" -ItemType Directory -Force | Out-Null
        Set-Content -LiteralPath "$Root/VcRedist/Public/Get-Test.ps1" -Value "function Get-Test { }"
        Set-Content -LiteralPath "$Root/VcRedist/VcRedist.psm1" -Value "function Get-Test { }; Export-ModuleMember -Function Get-Test"
        New-ModuleManifest -Path "$Root/VcRedist/VcRedist.psd1" -RootModule "VcRedist.psm1" -ModuleVersion "1.0.0" -FunctionsToExport "Get-Test" -Author "Test" -Description "Fixture"
        Set-Content -LiteralPath "$Root/VcRedist/VisualCRedistributables.json" -Value '{"Supported":[{"Version":"14.1.0.0","Architecture":"x64","Name":"Runtime"}],"Unsupported":[]}'
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## VERSION`n`n* Release changes`n`n## 1.0.0`n`n* Initial release"
        return $Root
    }

    function New-GalleryFixture {
        param (
            [System.String] $Root,
            [System.String] $Version = "1.0.1",
            [System.Management.Automation.SwitchParameter] $Different,
            [System.Management.Automation.SwitchParameter] $Extra,
            [System.Management.Automation.SwitchParameter] $Missing
        )
        $Path = Join-Path $TestDrive "$([System.Guid]::NewGuid()).nupkg"
        $Stream = [System.IO.File]::Create($Path)
        $Archive = New-Object -TypeName "System.IO.Compression.ZipArchive" -ArgumentList $Stream, ([System.IO.Compression.ZipArchiveMode]::Create)
        try {
            $ModulePath = "$Root/VcRedist"
            foreach ($File in Get-ChildItem -LiteralPath $ModulePath -Recurse -File) {
                $Name = $File.FullName.Substring($ModulePath.Length).TrimStart([char[]]"\/").Replace("\", "/")
                if ($Missing -and $Name -eq "VcRedist.psm1") { continue }
                $Entry = $Archive.CreateEntry($Name)
                $EntryStream = $Entry.Open()
                try {
                    if ($Different -and $Name -eq "VcRedist.psm1") {
                        $Bytes = [System.Text.Encoding]::UTF8.GetBytes("different contents")
                    }
                    else { $Bytes = [System.IO.File]::ReadAllBytes($File.FullName) }
                    $EntryStream.Write($Bytes, 0, $Bytes.Length)
                }
                finally { $EntryStream.Dispose() }
            }
            $NuspecStream = $Archive.CreateEntry("VcRedist.nuspec").Open()
            try {
                $Bytes = [System.Text.Encoding]::UTF8.GetBytes("<?xml version=`"1.0`"?><package xmlns=`"http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd`"><metadata><id>VcRedist</id><version>$Version</version></metadata></package>")
                $NuspecStream.Write($Bytes, 0, $Bytes.Length)
            }
            finally { $NuspecStream.Dispose() }
            $null = $Archive.CreateEntry("[Content_Types].xml")
            $null = $Archive.CreateEntry("_rels/.rels")
            if ($Extra) { $null = $Archive.CreateEntry("extra.ps1") }
        }
        finally { $Archive.Dispose(); $Stream.Dispose() }
        return $Path
    }
}

Describe "Release metadata and preparation" {
    BeforeEach {
        $Root = New-ReleaseFixture
    }

    It "Prepares an explicit stable version and validates documentation" {
        $Release = & $UpdateScript -Root $Root -Version "1.0.1"
        $Release.Tag | Should -BeExactly "v1.0.1"
        $Release.Notes | Should -BeExactly "* Release changes"
        (& $MetadataScript -Root $Root -RequireDocumentation -Tag "v1.0.1").FullVersion | Should -BeExactly "1.0.1"
    }

    It "Prepares the real module without changing its identity or export contract" {
        $Root = Join-Path $TestDrive "real-module"
        New-Item -Path $Root -ItemType Directory -Force | Out-Null
        Copy-Item -LiteralPath "$Repository/VcRedist", "$Repository/docs" -Destination $Root -Recurse
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## VERSION`n`n* Fixture release changes"
        $Before = Import-PowerShellDataFile -LiteralPath "$Root/VcRedist/VcRedist.psd1"
        $CurrentVersion = [System.Version]$Before.ModuleVersion
        $NewVersion = "{0}.{1}.{2}" -f $CurrentVersion.Major, $CurrentVersion.Minor, ($CurrentVersion.Build + 1)
        $null = & $UpdateScript -Root $Root -Version $NewVersion
        $After = Import-PowerShellDataFile -LiteralPath "$Root/VcRedist/VcRedist.psd1"
        $After.GUID | Should -BeExactly $Before.GUID
        $After.PowerShellVersion | Should -BeExactly $Before.PowerShellVersion
        @($After.AliasesToExport) | Should -Be @($Before.AliasesToExport)
        @($After.FunctionsToExport) | Should -Be @($Before.FunctionsToExport)
        $After.PrivateData.PSData.Prerelease | Should -BeNullOrEmpty
        (& $MetadataScript -Root $Root -RequireDocumentation).Version | Should -BeExactly $NewVersion
    }

    It "Prepares a prerelease without changing the numeric version in its tag" {
        $Release = & $UpdateScript -Root $Root -Version "2.0.0" -Prerelease "beta1"
        $Release.Tag | Should -BeExactly "v2.0.0-beta1"
        $Release.Prerelease | Should -BeExactly "beta1"
    }

    It "Accepts existing release notes for <FullVersion>" -ForEach @(
        @{ Version = "1.0.1"; Prerelease = ""; FullVersion = "1.0.1" }
        @{ Version = "2.0.0"; Prerelease = "beta2"; FullVersion = "2.0.0-beta2" }
    ) {
        $Changelog = "# Changelog`n`n## $FullVersion`n`n* Release changes`n`n## 1.0.0`n`n* Initial release"
        [System.IO.File]::WriteAllText("$Root/docs/changelog.md", $Changelog)
        $Release = & $UpdateScript -Root $Root -Version $Version -Prerelease $Prerelease
        $Release.FullVersion | Should -BeExactly $FullVersion
        $Release.Notes | Should -BeExactly "* Release changes"
        [System.IO.File]::ReadAllText("$Root/docs/changelog.md") | Should -BeExactly $Changelog
    }

    It "Rejects duplicate or lower stable versions" -ForEach @("1.0.0", "0.9.9") {
        { & $UpdateScript -Root $Root -Version $_ } | Should -Throw "*newer*"
    }

    It "Rejects invalid prerelease casing and version shapes" {
        { & $UpdateScript -Root $Root -Version "1.0.1" -Prerelease "Beta1" } | Should -Throw
        { & $UpdateScript -Root $Root -Version "01.0.1" } | Should -Throw
        { & $UpdateScript -Root $Root -Version "1.0.1.0" } | Should -Throw
    }

    It "Allows promotion from prerelease to stable at the same numeric version" {
        Update-ModuleManifest -Path "$Root/VcRedist/VcRedist.psd1" -ModuleVersion "2.0.0" -Prerelease "beta1"
        (& $UpdateScript -Root $Root -Version "2.0.0").FullVersion | Should -BeExactly "2.0.0"
    }

    It "Allows only increasing prerelease labels at the same numeric version" {
        Update-ModuleManifest -Path "$Root/VcRedist/VcRedist.psd1" -ModuleVersion "2.0.0" -Prerelease "beta2"
        { & $UpdateScript -Root $Root -Version "2.0.0" -Prerelease "beta1" } | Should -Throw "*newer*"
        { & $UpdateScript -Root $Root -Version "2.0.0" -Prerelease "beta2" } | Should -Throw "*newer*"
        (& $UpdateScript -Root $Root -Version "2.0.0" -Prerelease "rc1").FullVersion | Should -BeExactly "2.0.0-rc1"
    }

    It "Rejects missing or empty placeholder notes before changing the manifest" {
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## 1.0.0`n`n* Old"
        { & $UpdateScript -Root $Root -Version "1.0.1" } | Should -Throw "*VERSION*"
        (& $MetadataScript -Root $Root).Version | Should -BeExactly "1.0.0"
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## VERSION`n`n## 1.0.0`n`n* Old"
        { & $UpdateScript -Root $Root -Version "1.0.1" } | Should -Throw "*empty*"
    }

    It "Rejects a different release heading before changing the manifest" {
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## 2.0.0-beta1`n`n* Old"
        { & $UpdateScript -Root $Root -Version "2.0.0" -Prerelease "beta2" } | Should -Throw "*VERSION*"
        (& $MetadataScript -Root $Root).Version | Should -BeExactly "1.0.0"
    }

    It "Rejects duplicate release headings and empty numbered notes" {
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## 1.0.1`n`n* Notes`n`n## VERSION`n`n* Other"
        { & $UpdateScript -Root $Root -Version "1.0.1" } | Should -Throw "*exactly one*"
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## VERSION`n`n* Notes`n`n## 1.0.1`n`n* Other"
        { & $UpdateScript -Root $Root -Version "1.0.1" } | Should -Throw "*exactly one*"
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## 1.0.1`n`n* Notes`n`n## 1.0.1`n`n* Other"
        { & $UpdateScript -Root $Root -Version "1.0.1" } | Should -Throw "*exactly one*"
        Set-Content -LiteralPath "$Root/docs/changelog.md" -Value "# Changelog`n`n## 1.0.1`n`n## 1.0.0`n`n* Old"
        { & $UpdateScript -Root $Root -Version "1.0.1" } | Should -Throw "*empty*"
        (& $MetadataScript -Root $Root).Version | Should -BeExactly "1.0.0"
    }

    It "Rejects mismatched tags, stale documentation and exports" {
        $null = & $UpdateScript -Root $Root -Version "1.0.1"
        { & $MetadataScript -Root $Root -Tag "v1.0.2" } | Should -Throw "*does not match*"
        Set-Content -LiteralPath "$Root/docs/versions.md" -Value "stale documentation"
        { & $MetadataScript -Root $Root -RequireDocumentation } | Should -Throw "*documentation*"
        Update-ModuleManifest -Path "$Root/VcRedist/VcRedist.psd1" -FunctionsToExport "*"
        { & $MetadataScript -Root $Root } | Should -Throw "*FunctionsToExport*"
    }

    It "Generates docs from both bundled schema versions" {
        $OldDocument = & $DocumentScript -Root $Root -Version "1.0.1"
        Set-Content -LiteralPath "$Root/VcRedist/VisualCRedistributables.json" -Value '{"SchemaVersion":5,"Entries":[{"Version":"14.1.0.0","Architecture":"x64","Name":"Runtime","Supported":true}]}'
        (& $DocumentScript -Root $Root -Version "1.0.1") | Should -BeExactly $OldDocument
        Set-Content -LiteralPath "$Root/VcRedist/VisualCRedistributables.json" -Value '{}'
        { & $DocumentScript -Root $Root -Version "1.0.1" } | Should -Throw "*schema*"
    }
}

Describe "Gallery publishing recovery" {
    BeforeEach {
        $Root = New-ReleaseFixture
        $null = & $UpdateScript -Root $Root -Version "1.0.1"
        $Package = New-GalleryFixture -Root $Root
        $PreviousKey = $env:NUGETAPIKEY
        $env:NUGETAPIKEY = "unit-test-placeholder"
        Mock Get-Module { [PSCustomObject]@{ Version = [System.Version]"2.2.5" } } -ParameterFilter { $Name -eq "PowerShellGet" }
        Mock Import-Module {} -ParameterFilter { $Name -eq "PowerShellGet" }
        Mock Install-Module { throw "Unexpected dependency installation in unit tests." }
        Mock Publish-Module {}
        Mock Start-Sleep {}
        Mock Invoke-WebRequest { if ($OutFile) { Copy-Item -LiteralPath $Package -Destination $OutFile } }
    }

    AfterEach {
        $env:NUGETAPIKEY = $PreviousKey
    }

    It "Recovers an identical existing package without republishing" {
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Not -Throw
        Should -Invoke Publish-Module -Times 0
    }

    It "Emits opt-in verification diagnostics without leaking the publishing credential or success-stream values" {
        $QuietOutput = @(& $PublishScript -Root $Root -Tag "v1.0.1" -Verbose:$false 4>&1)
        @($QuietOutput | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }).Count | Should -Be 0

        $Output = @(& $PublishScript -Root $Root -Tag "v1.0.1" -Verbose 4>&1)
        $Messages = @($Output | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } | ForEach-Object { $_.Message }) -join "`n"
        $Messages | Should -Match "Release metadata validated"
        $Messages | Should -Match "SHA256 matches"
        $Messages | Should -Match "matches the validated artifact"
        $Messages | Should -Match "Removing temporary Gallery package"
        ($Output | Out-String) | Should -Not -Match ([System.Text.RegularExpressions.Regex]::Escape($env:NUGETAPIKEY))
        @($Output | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] }).Count | Should -Be 0
        Should -Invoke Publish-Module -Times 0
    }

    It "Rejects existing packages with different or unexpected module files" {
        $Package = New-GalleryFixture -Root $Root -Different
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Throw "*differs*"
        $Package = New-GalleryFixture -Root $Root -Extra
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Throw "*unexpected files*"
        Should -Invoke Publish-Module -Times 0
    }

    It "Rejects missing files and corrupt Gallery packages without republishing" {
        $Package = New-GalleryFixture -Root $Root -Missing
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Throw "*missing*"
        Set-Content -LiteralPath $Package -Value "not a ZIP file"
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Throw
        Should -Invoke Publish-Module -Times 0
    }

    It "Publishes a missing version and verifies its package" {
        Mock Invoke-WebRequest {
            if (-not $script:Published) { throw (New-Object -TypeName "ReleaseHttpException" -ArgumentList 404) }
            if ($OutFile) { Copy-Item -LiteralPath $Package -Destination $OutFile }
        }
        $script:Published = $false
        Mock Publish-Module { $script:Published = $true }
        $Output = @(& $PublishScript -Root $Root -Tag "v1.0.1" -Verbose 4>&1)
        $Messages = @($Output | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] } | ForEach-Object { $_.Message }) -join "`n"
        $Messages | Should -Match "not published \(HTTP 404\)"
        $Messages | Should -Match "Publish-Module completed"
        $Messages | Should -Match "Gallery verification attempt 1 of 20"
        ($Output | Out-String) | Should -Not -Match ([System.Text.RegularExpressions.Regex]::Escape($env:NUGETAPIKEY))
        Should -Invoke Publish-Module -Times 1
        Should -Invoke Invoke-WebRequest -Times 3 -Exactly
        Should -Invoke Invoke-WebRequest -ParameterFilter { $Uri -like "*/Packages(Id='VcRedist',Version='1.0.1')" } -Times 2 -Exactly
        Should -Invoke Invoke-WebRequest -ParameterFilter { $OutFile } -Times 1 -Exactly
    }

    It "Does not mistake a redirect to another version for the requested package" {
        $Stale = New-GalleryFixture -Root $Root -Version "1.0.0"
        $script:Published = $false
        $script:Downloads = 0
        Mock Invoke-WebRequest {
            if (-not $OutFile) {
                if (-not $script:Published) { throw (New-Object -TypeName "ReleaseHttpException" -ArgumentList 404) }
                return
            }
            $script:Downloads++
            if ($script:Downloads -eq 1) { Copy-Item -LiteralPath $Stale -Destination $OutFile }
            else { Copy-Item -LiteralPath $Package -Destination $OutFile }
        }
        Mock Publish-Module { $script:Published = $true }
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Not -Throw
        Should -Invoke Publish-Module -Times 1 -Exactly
        Should -Invoke Start-Sleep -Times 1 -Exactly

        Mock Invoke-WebRequest { if ($OutFile) { Copy-Item -LiteralPath $Stale -Destination $OutFile } }
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Throw "*could not be verified*"
    }

    It "Fails explicitly when Gallery verification never becomes available" {
        Mock Invoke-WebRequest { throw (New-Object -TypeName "ReleaseHttpException" -ArgumentList 404) }
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Throw "*could not be verified*"
        Should -Invoke Publish-Module -Times 1
        Should -Invoke Start-Sleep -Times 19 -Exactly
    }

    It "Does not mistake Gallery network or authorization errors for a missing version" {
        Mock Invoke-WebRequest { throw (New-Object -TypeName "ReleaseHttpException" -ArgumentList 403) }
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Throw "*HTTP failure*"
        Should -Invoke Publish-Module -Times 0
    }

    It "Requires a publishing credential" {
        $env:NUGETAPIKEY = ""
        { & $PublishScript -Root $Root -Tag "v1.0.1" } | Should -Throw "*NUGETAPIKEY*"
        Should -Invoke Publish-Module -Times 0
    }
}

Describe "Analyzer keyword detection" {
    It "Accepts enum members while still rejecting uppercase keywords" {
        Import-Module -Name "PSScriptAnalyzer" -RequiredVersion "1.25.0"
        $Settings = Join-Path $Repository ".rules/PSScriptAnalyzerSettings.psd1"
        @(Invoke-ScriptAnalyzer -ScriptDefinition "[System.Management.Automation.ActionPreference]::Continue" -Settings $Settings).Count | Should -Be 0
        @(Invoke-ScriptAnalyzer -ScriptDefinition "IF (`$true) { }" -Settings $Settings).Count | Should -BeGreaterThan 0
    }
}
