<#
    .SYNOPSIS
        Publishes a validated module, verifying Gallery contents before accepting retries.
    .PARAMETER Root
        Staged release directory containing VcRedist and docs.
    .PARAMETER Tag
        Exact release tag.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [System.String] $Root,
    [Parameter(Mandatory = $true)]
    [System.String] $Tag
)

$ErrorActionPreference = "Stop"
$Metadata = & (Join-Path -Path $PSScriptRoot -ChildPath "Get-ReleaseMetadata.ps1") -Root $Root -Tag $Tag -RequireDocumentation
if (-not $env:NUGETAPIKEY) { throw "Configure the NUGETAPIKEY publishing secret." }
if (-not (Get-Module -ListAvailable -Name "PowerShellGet" | Where-Object Version -EQ "2.2.5")) {
    Install-Module -Name "PowerShellGet" -RequiredVersion "2.2.5" -Scope "CurrentUser" -Force -Repository "PSGallery"
}
Import-Module -Name "PowerShellGet" -RequiredVersion "2.2.5" -Force
Add-Type -AssemblyName "System.IO.Compression"
$ModulePath = Join-Path -Path $Root -ChildPath "VcRedist"
$PackagePath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "VcRedist-$([System.Guid]::NewGuid()).nupkg"
$Uri = "https://www.powershellgallery.com/api/v2/package/VcRedist/$($Metadata.FullVersion)"

function Test-GalleryPackage {
    try {
        Invoke-WebRequest -Uri $Uri -OutFile $PackagePath -UseBasicParsing -ErrorAction "Stop" | Out-Null
    }
    catch {
        if ($_.Exception.Response -and [System.Int32]$_.Exception.Response.StatusCode -eq 404) { return $false }
        throw
    }
    $Stream = [System.IO.File]::OpenRead($PackagePath)
    $Archive = $null
    try {
        $Archive = New-Object -TypeName "System.IO.Compression.ZipArchive" -ArgumentList $Stream
        $Files = @(Get-ChildItem -LiteralPath $ModulePath -Recurse -File)
        foreach ($File in $Files) {
            $RelativePath = $File.FullName.Substring($ModulePath.Length).TrimStart([char[]]"\/").Replace("\", "/")
            $Entry = $Archive.GetEntry($RelativePath)
            if ($null -eq $Entry) { throw "Gallery package is missing '$RelativePath'; refusing to reuse this version." }
            $EntryStream = $Entry.Open()
            $Hasher = [System.Security.Cryptography.SHA256]::Create()
            try {
                $GalleryHash = [System.BitConverter]::ToString($Hasher.ComputeHash($EntryStream)).Replace("-", "")
                $LocalHash = (Get-FileHash -LiteralPath $File.FullName -Algorithm "SHA256").Hash
                if ($GalleryHash -cne $LocalHash) { throw "Gallery file '$RelativePath' differs from the validated artifact. Choose a new version; do not overwrite or move its tag." }
            }
            finally {
                $Hasher.Dispose()
                $EntryStream.Dispose()
            }
        }
        $PackageFiles = @($Archive.Entries | Where-Object {
            $_.Name -and $_.FullName -notlike "_rels/*" -and $_.FullName -notlike "package/*" -and
            $_.FullName -ne "[Content_Types].xml" -and $_.FullName -notlike "*.nuspec" -and $_.FullName -ne "PSGetModuleInfo.xml"
        })
        if ($PackageFiles.Count -ne $Files.Count) { throw "Gallery package contains unexpected files; refusing to reuse this version." }
    }
    finally {
        if ($null -ne $Archive) { $Archive.Dispose() }
        $Stream.Dispose()
    }
    return $true
}

try {
    if (Test-GalleryPackage) {
        Write-Information -MessageData "Gallery already contains $($Metadata.FullVersion) with identical module contents; recovering the existing release." -InformationAction "Continue"
    }
    else {
        Publish-Module -Path $ModulePath -Repository "PSGallery" -NuGetApiKey $env:NUGETAPIKEY -ErrorAction "Stop"
        $Verified = $false
        for ($Attempt = 1; $Attempt -le 6; $Attempt++) {
            if (Test-GalleryPackage) { $Verified = $true; break }
            Write-Information -MessageData "Gallery package is not available yet (attempt $Attempt of 6)." -InformationAction "Continue"
            if ($Attempt -lt 6) { Start-Sleep -Seconds 20 }
        }
        if (-not $Verified) { throw "Gallery publication could not be verified. Leave the release draft and rerun the workflow once the package is available." }
    }
}
finally {
    if (Test-Path -LiteralPath $PackagePath) { Remove-Item -LiteralPath $PackagePath -Force }
}
