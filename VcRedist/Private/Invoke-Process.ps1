function Invoke-Process {
    <#PSScriptInfo
    .VERSION 1.4
    .GUID b787dc5d-8d11-45e9-aeef-5cf3a1f690de
    .AUTHOR Adam Bertram
    .COMPANYNAME Adam the Automator, LLC
    .TAGS Processes
    #>
    <#
        .DESCRIPTION
            Invoke-Process is a simple wrapper function that aims to "PowerShellyify" launching typical external processes. There
            are lots of ways to invoke processes in PowerShell with Start-Process, Invoke-Expression, & and others but none account
            well for the various streams and exit codes that an external process returns. Also, it's hard to write good tests
            when launching external processes.

            This function ensures any errors are sent to the error stream, standard output is sent via the Output stream and any
            time the process returns an exit code other than 0, treat it as an error.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $FilePath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $ArgumentList,

        # Exit codes treated as success. Some tools (e.g. robocopy) use non-zero codes for success
        [Parameter()]
        [System.Int32[]] $SuccessExitCodes = @(0)
    )

    $ErrorActionPreference = "Stop"
    $stdOutTempFile = $null
    $stdErrTempFile = $null
    try {
        if ($PSCmdlet.ShouldProcess("Process [$($FilePath)]", "Run with args: [$($ArgumentList)]")) {
            $TempPath = [System.IO.Path]::GetTempPath()
            $stdOutTempFile = Join-Path -Path $TempPath -ChildPath ([System.Guid]::NewGuid().Guid)
            $stdErrTempFile = Join-Path -Path $TempPath -ChildPath ([System.Guid]::NewGuid().Guid)

            $startProcessParams = @{
                FilePath               = $FilePath
                RedirectStandardError  = $stdErrTempFile
                RedirectStandardOutput = $stdOutTempFile
                Wait                   = $true
                PassThru               = $true
                NoNewWindow            = $true
            }
            if ($PSBoundParameters.ContainsKey("ArgumentList")) { $startProcessParams.ArgumentList = $ArgumentList }
            $cmd = Start-Process @startProcessParams

            $cmdOutput = Get-Content -LiteralPath $stdOutTempFile -Raw -ErrorAction "SilentlyContinue"
            $cmdError = Get-Content -LiteralPath $stdErrTempFile -Raw -ErrorAction "SilentlyContinue"
            if ($SuccessExitCodes -notcontains $cmd.ExitCode) {
                $Detail = if ($cmdError) { $cmdError.Trim() } elseif ($cmdOutput) { $cmdOutput.Trim() } else { "No output captured." }
                throw "Process '$FilePath' exited with code $($cmd.ExitCode). $Detail"
            }
            if ([System.String]::IsNullOrEmpty($cmdOutput) -eq $false) {
                Write-Output -InputObject $cmdOutput
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        foreach ($TempFile in $stdOutTempFile, $stdErrTempFile) {
            if ($TempFile) { Remove-Item -LiteralPath $TempFile -Force -ErrorAction "Ignore" }
        }
    }
}
