<#
    .SYNOPSIS
        Publishes a validated module, verifying Gallery contents before accepting retries.
    .PARAMETER Root
        Staged release directory containing VcRedist and docs.
    .PARAMETER Tag
        Exact release tag.
    .EXAMPLE
        ./ci/Publish-Release.ps1 -Root ./staged -Tag v5.1.0-beta1 -Verbose
        Shows publication and package verification diagnostics without logging the API key.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [System.String] $Root,
    [Parameter(Mandatory = $true)]
    [System.String] $Tag
)

$ErrorActionPreference = "Stop"
Write-Verbose -Message "Validating release metadata for tag '$Tag' in '$Root'."
$Metadata = & (Join-Path -Path $PSScriptRoot -ChildPath "Get-ReleaseMetadata.ps1") -Root $Root -Tag $Tag -RequireDocumentation
Write-Verbose -Message "Release metadata validated: version '$($Metadata.FullVersion)'."
if (-not $env:NUGETAPIKEY) { throw "Configure the NUGETAPIKEY publishing secret." }
Write-Verbose -Message "Publishing credential is configured."
if (-not (Get-Module -ListAvailable -Name "PowerShellGet" | Where-Object Version -EQ "2.2.5")) {
    Write-Verbose -Message "Installing PowerShellGet 2.2.5 from PSGallery for the current user."
    Install-Module -Name "PowerShellGet" -RequiredVersion "2.2.5" -Scope "CurrentUser" -Force -Repository "PSGallery"
}
Write-Verbose -Message "Importing PowerShellGet 2.2.5."
Import-Module -Name "PowerShellGet" -RequiredVersion "2.2.5" -Force
Add-Type -AssemblyName "System.IO.Compression"
$ModulePath = Join-Path -Path $Root -ChildPath "VcRedist"
$PackagePath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "VcRedist-$([System.Guid]::NewGuid()).nupkg"
# The package endpoint redirects unknown versions to the latest package instead of returning 404,
# so the OData entry is used to determine whether this exact version exists.
$EntryUri = "https://www.powershellgallery.com/api/v2/Packages(Id='VcRedist',Version='$($Metadata.FullVersion)')"
$Uri = "https://www.powershellgallery.com/api/v2/package/VcRedist/$($Metadata.FullVersion)"
$MaxAttempts = 20
$RetrySeconds = 30

function Test-GalleryPackage {
    Write-Verbose -Message "Looking up Gallery package entry '$EntryUri'."
    try {
        Invoke-WebRequest -Uri $EntryUri -UseBasicParsing -ErrorAction "Stop" | Out-Null
    }
    catch {
        if ($_.Exception.Response -and [System.Int32]$_.Exception.Response.StatusCode -eq 404) {
            Write-Verbose -Message "Gallery package '$($Metadata.FullVersion)' is not published (HTTP 404)."
            return $false
        }
        Write-Verbose -Message "Gallery package lookup failed; propagating the error without publishing or retrying."
        throw
    }
    Write-Verbose -Message "Gallery lists '$($Metadata.FullVersion)'; downloading package from '$Uri' to '$PackagePath'."
    Invoke-WebRequest -Uri $Uri -OutFile $PackagePath -UseBasicParsing -ErrorAction "Stop" | Out-Null
    $Stream = [System.IO.File]::OpenRead($PackagePath)
    $Archive = $null
    try {
        $Archive = New-Object -TypeName "System.IO.Compression.ZipArchive" -ArgumentList $Stream
        # Guards against a stale CDN or redirect returning a different package version.
        $NuspecEntries = @($Archive.Entries | Where-Object { $_.FullName -notmatch "/" -and $_.FullName -like "*.nuspec" })
        if ($NuspecEntries.Count -ne 1) { throw "Gallery package does not contain exactly one root .nuspec file; refusing to reuse this version." }
        $NuspecReader = New-Object -TypeName "System.IO.StreamReader" -ArgumentList $NuspecEntries[0].Open()
        try { [System.Xml.XmlDocument]$Nuspec = $NuspecReader.ReadToEnd() }
        finally { $NuspecReader.Dispose() }
        $PackageId = [System.String]$Nuspec.package.metadata.id
        $PackageVersion = [System.String]$Nuspec.package.metadata.version
        Write-Verbose -Message "Downloaded package identity: '$PackageId' version '$PackageVersion'."
        if ($PackageId -ne "VcRedist") { throw "Gallery returned package '$PackageId' instead of 'VcRedist'; refusing to reuse this version." }
        if ($PackageVersion -ne $Metadata.FullVersion) {
            Write-Verbose -Message "Gallery returned version '$PackageVersion' instead of '$($Metadata.FullVersion)'; treating the requested version as not available."
            return $false
        }
        $Files = @(Get-ChildItem -LiteralPath $ModulePath -Recurse -File)
        Write-Verbose -Message "Verifying $($Files.Count) staged module files from '$ModulePath' against the downloaded package."
        foreach ($File in $Files) {
            $RelativePath = $File.FullName.Substring($ModulePath.Length).TrimStart([char[]]"\/").Replace("\", "/")
            Write-Verbose -Message "Verifying Gallery file '$RelativePath'."
            $Entry = $Archive.GetEntry($RelativePath)
            if ($null -eq $Entry) { throw "Gallery package is missing '$RelativePath'; refusing to reuse this version." }
            $EntryStream = $Entry.Open()
            $Hasher = [System.Security.Cryptography.SHA256]::Create()
            try {
                $GalleryHash = [System.BitConverter]::ToString($Hasher.ComputeHash($EntryStream)).Replace("-", "")
                $LocalHash = (Get-FileHash -LiteralPath $File.FullName -Algorithm "SHA256").Hash
                if ($GalleryHash -cne $LocalHash) { throw "Gallery file '$RelativePath' differs from the validated artifact. Choose a new version; do not overwrite or move its tag." }
                Write-Verbose -Message "SHA256 matches for '$RelativePath': $LocalHash."
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
        Write-Verbose -Message "Package contains $($PackageFiles.Count) module files; expected $($Files.Count)."
        if ($PackageFiles.Count -ne $Files.Count) { throw "Gallery package contains unexpected files; refusing to reuse this version." }
        Write-Verbose -Message "Gallery package '$($Metadata.FullVersion)' matches the validated artifact."
    }
    finally {
        if ($null -ne $Archive) { $Archive.Dispose() }
        $Stream.Dispose()
    }
    return $true
}

try {
    Write-Verbose -Message "Checking whether Gallery already contains '$($Metadata.FullVersion)' before publishing."
    if (Test-GalleryPackage) {
        Write-Information -MessageData "Gallery already contains $($Metadata.FullVersion) with identical module contents; recovering the existing release." -InformationAction "Continue"
    }
    else {
        Write-Verbose -Message "Publishing module '$ModulePath' version '$($Metadata.FullVersion)' to PSGallery."
        Publish-Module -Path $ModulePath -Repository "PSGallery" -NuGetApiKey $env:NUGETAPIKEY -ErrorAction "Stop"
        Write-Verbose -Message "Publish-Module completed; starting Gallery verification."
        $Verified = $false
        for ($Attempt = 1; $Attempt -le $MaxAttempts; $Attempt++) {
            Write-Verbose -Message "Gallery verification attempt $Attempt of $MaxAttempts."
            if (Test-GalleryPackage) { $Verified = $true; break }
            Write-Information -MessageData "Gallery package is not available yet (attempt $Attempt of $MaxAttempts)." -InformationAction "Continue"
            if ($Attempt -lt $MaxAttempts) {
                Write-Verbose -Message "Waiting $RetrySeconds seconds before the next Gallery verification attempt."
                Start-Sleep -Seconds $RetrySeconds
            }
        }
        if (-not $Verified) { throw "Gallery publication could not be verified. Leave the release draft and rerun the workflow once the package is available." }
    }
}
finally {
    if (Test-Path -LiteralPath $PackagePath) {
        Write-Verbose -Message "Removing temporary Gallery package '$PackagePath'."
        Remove-Item -LiteralPath $PackagePath -Force
    }
}
