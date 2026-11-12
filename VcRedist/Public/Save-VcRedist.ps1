function Save-VcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Get-VcRedist")]
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/save-vcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Pass a VcList object from Get-VcList.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path = (Resolve-Path -LiteralPath $PWD),

        [Parameter(Mandatory = $false, Position = 3)]
        [System.String] $Proxy,

        [Parameter(Mandatory = $false, Position = 4)]
        [System.Management.Automation.PSCredential]
        $ProxyCredential = [System.Management.Automation.PSCredential]::Empty,

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidateNotNullOrEmpty()]
        [System.String] $UserAgent = (Get-VcUserAgent),

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $ShowProgress,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $SkipAuthenticodeValidation
    )

    begin {
        $DownloadTimeout = [System.Int32](Get-VcConfig).Download.TimeoutSeconds
        $ShowProgressBar = $PSBoundParameters.ContainsKey("Verbose") -or $PSBoundParameters.ContainsKey("ShowProgress")

        # Create the target path if it does not exist; fail before any download if it is not a usable folder
        $FullPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Path)
        if (Test-Path -LiteralPath $FullPath -PathType "Leaf") {
            throw [System.IO.IOException]::New("The path '$FullPath' is a file, not a folder.")
        }
        if (-not (Test-Path -LiteralPath $FullPath -PathType "Container")) {
            if ($PSCmdlet.ShouldProcess($FullPath, "Create")) {
                try {
                    New-Item -Path $FullPath -ItemType "Directory" -Force -ErrorAction "Stop" > $null
                }
                catch {
                    throw [System.IO.DirectoryNotFoundException]::New("Unable to create the path '$FullPath': $($_.Exception.Message)")
                }
            }
        }
    }

    process {
        foreach ($VcRedist in $VcList) {
            foreach ($Property in @("URI", "Release", "Version", "Architecture")) {
                $PropertyInfo = $VcRedist.PSObject.Properties[$Property]
                if ($null -eq $PropertyInfo -or [System.String]::IsNullOrWhiteSpace([System.String]$PropertyInfo.Value)) {
                    throw [System.Management.Automation.ValidationMetadataException]::New("Property '$Property' is missing or empty.")
                }
            }
            if ($VcRedist.Release -notmatch "^[0-9]{2,4}$") {
                throw [System.Management.Automation.ValidationMetadataException]::New("Release '$($VcRedist.Release)' is invalid.")
            }
            $ParsedVersion = $null
            if (-not [System.Version]::TryParse([System.String]$VcRedist.Version, [ref] $ParsedVersion)) {
                throw [System.Management.Automation.ValidationMetadataException]::New("Version '$($VcRedist.Version)' is invalid.")
            }
            if (@("x86", "x64", "arm64") -notcontains $VcRedist.Architecture) {
                throw [System.Management.Automation.ValidationMetadataException]::New("Architecture '$($VcRedist.Architecture)' is invalid.")
            }

            # Only download from HTTPS URIs on the allowed host list
            if (-not (Test-VcDownloadUri -Uri $VcRedist.URI)) {
                throw [System.Management.Automation.ValidationMetadataException]::New("The URI is not HTTPS or not on the allowed host list: '$($VcRedist.URI)'.")
            }

            # Build the path to save the VcRedist into; Create the folder to store the downloaded file. Skip if it exists
            $TargetDirectory = [System.IO.Path]::Combine($FullPath, $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
            $DirectoryToCheck = $FullPath
            foreach ($Segment in @($VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)) {
                $DirectoryToCheck = Join-Path -Path $DirectoryToCheck -ChildPath $Segment
                if (Test-Path -LiteralPath $DirectoryToCheck -PathType "Leaf") {
                    throw [System.IO.IOException]::New("The path '$DirectoryToCheck' is a file, not a folder.")
                }
            }
            Write-Verbose -Message "Test directory exists: $TargetDirectory."
            if (Test-Path -LiteralPath $TargetDirectory -PathType "Container") {
                Write-Verbose -Message "Directory exists: $TargetDirectory. Skipping."
            }
            else {
                if ($PSCmdlet.ShouldProcess($TargetDirectory, "Create")) {
                    New-Item -Path $TargetDirectory -ItemType "Directory" -Force -ErrorAction "Stop" > $null
                }
            }

            # Test whether the VcRedist is already on disk
            $ParsedUri = [System.Uri]$VcRedist.URI
            $InstallerName = [System.IO.Path]::GetFileName($ParsedUri.LocalPath)
            if ([System.String]::IsNullOrWhiteSpace($InstallerName)) {
                throw [System.Management.Automation.ValidationMetadataException]::New("The URI does not contain an installer filename: '$($VcRedist.URI)'.")
            }
            $TargetVcRedist = Join-Path -Path $TargetDirectory -ChildPath $InstallerName
            Write-Verbose -Message "Testing for downloaded VcRedist: $($TargetVcRedist)"

            $DownloadRequired = $true
            if (Test-Path -LiteralPath $TargetVcRedist -PathType "Leaf") {
                $ProductVersion = $null
                $ExistingVersion = (Get-Item -LiteralPath $TargetVcRedist).VersionInfo.ProductVersion
                if (-not [System.Version]::TryParse($ExistingVersion, [ref] $ProductVersion) -or ([System.Version]$VcRedist.Version -gt $ProductVersion)) {
                    Write-Verbose -Message "Manifest version: '$($VcRedist.Version)' > file version: '$ExistingVersion'."
                }
                else {
                    # Evergreen manifest URIs can return an installer newer than the manifest version.
                    Write-Verbose -Message "Manifest version: '$($VcRedist.Version)' matches file version: '$ExistingVersion'."
                    $DownloadRequired = $false
                }
            }

            if ($DownloadRequired -eq $true) {
                if ($PSCmdlet.ShouldProcess($VcRedist.URI, "Download")) {
                    # Download to a temporary file, verify, then move into place so a failed download never leaves a partial installer
                    $TempFile = "$TargetVcRedist.$([System.Guid]::NewGuid().Guid).download"
                    try {
                        Write-Verbose -Message "Download VcRedist: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'"
                        $iwrParams = @{
                            Uri          = $VcRedist.URI
                            OutFile      = $TempFile
                            UserAgent    = $UserAgent
                            TimeoutSec   = $DownloadTimeout
                            ShowProgress = $ShowProgressBar
                        }
                        if ($PSBoundParameters.ContainsKey("Proxy")) { $iwrParams.Proxy = $Proxy }
                        if ($PSBoundParameters.ContainsKey("ProxyCredential")) { $iwrParams.ProxyCredential = $ProxyCredential }
                        Invoke-VcWebRequest @iwrParams | Out-Null

                        if (-not $SkipAuthenticodeValidation) {
                            Assert-VcSignature -Path $TempFile | Out-Null
                        }
                        else {
                            Write-Verbose -Message "Skipping Authenticode validation: $TargetVcRedist."
                        }
                        Move-Item -LiteralPath $TempFile -Destination $TargetVcRedist -Force -ErrorAction "Stop"
                    }
                    finally {
                        if (Test-Path -LiteralPath $TempFile) { Remove-Item -LiteralPath $TempFile -Force -ErrorAction "SilentlyContinue" }
                    }
                }
                else {
                    continue
                }
            }
            else {
                Write-Verbose -Message "VcRedist exists: $TargetVcRedist."
                if (-not $SkipAuthenticodeValidation) {
                    Assert-VcSignature -Path $TargetVcRedist | Out-Null
                }
                else {
                    Write-Verbose -Message "Skipping Authenticode validation: $TargetVcRedist."
                }
            }

            # Return the $VcList object on the pipeline with the Path property pointing to the downloaded file
            Write-Verbose -Message "Add Path property: $TargetVcRedist"
            $VcRedist | Add-Member -MemberType "NoteProperty" -Name "Path" -Value $TargetVcRedist -Force
            Write-Output -InputObject $VcRedist
        }
    }

    end { }
}
