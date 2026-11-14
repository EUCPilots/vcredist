function Invoke-Process {
    <#PSScriptInfo
    .VERSION 1.4
    .GUID b787dc5d-8d11-45e9-aeef-5cf3a1f690de
    .AUTHOR Adam Bertram
    .COMPANYNAME Adam the Automator, LLC
    .TAGS Processes
    #>
    <#
    .SYNOPSIS
        Starts a process, captures its output, and validates its exit code.

    .DESCRIPTION
        Standard output is returned as a single string. Standard error is written
        to the error stream on success and included in the terminating error on
        failure. The process is stopped if it exceeds the timeout or output limit.

    .PARAMETER FilePath
        Executable path or command name to start.

    .PARAMETER ArgumentList
        Individual process arguments. Each argument is escaped for the Windows
        command-line convention used by Start-Process.

    .PARAMETER SuccessExitCodes
        Exit codes that indicate success. Defaults to 0.

    .PARAMETER TimeoutSeconds
        Maximum process duration in seconds. Defaults to 1800.

    .PARAMETER MaximumOutputBytes
        Maximum combined size of captured standard output and standard error.
        Defaults to 10 MiB.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String] $FilePath,

        [Parameter()]
        [AllowEmptyCollection()]
        [ValidateScript({ $null -ne $_ })]
        [System.Object[]] $ArgumentList,

        # Exit codes treated as success. Some tools (e.g. robocopy) use non-zero codes for success
        [Parameter()]
        [System.Int32[]] $SuccessExitCodes = @(0),

        [Parameter()]
        [ValidateRange(1, 2147483)]
        [System.Int32] $TimeoutSeconds = 1800,

        [Parameter()]
        [ValidateRange(1, 2147483647)]
        [System.Int64] $MaximumOutputBytes = 10MB
    )

    $ErrorActionPreference = "Stop"
    $stdOutTempFile = $null
    $stdErrTempFile = $null
    $cmd = $null
    try {
        if ($PSCmdlet.ShouldProcess("Process [$($FilePath)]", "Run")) {
            $stdOutTempFile = [System.IO.Path]::GetTempFileName()
            $stdErrTempFile = [System.IO.Path]::GetTempFileName()

            $quoteArgument = {
                param ([System.String] $Value)

                $Builder = New-Object System.Text.StringBuilder
                [void]$Builder.Append([char]34)
                $BackslashCount = 0
                for ($Index = 0; $Index -lt $Value.Length; $Index++) {
                    $Character = $Value[$Index]
                    if ($Character -eq [char]92) {
                        $BackslashCount++
                        continue
                    }

                    if ($Character -eq [char]34) {
                        for ($Slash = 0; $Slash -lt (2 * $BackslashCount + 1); $Slash++) {
                            [void]$Builder.Append([char]92)
                        }
                        [void]$Builder.Append([char]34)
                    }
                    else {
                        for ($Slash = 0; $Slash -lt $BackslashCount; $Slash++) {
                            [void]$Builder.Append([char]92)
                        }
                        [void]$Builder.Append($Character)
                    }
                    $BackslashCount = 0
                }

                for ($Slash = 0; $Slash -lt (2 * $BackslashCount); $Slash++) {
                    [void]$Builder.Append([char]92)
                }
                [void]$Builder.Append([char]34)
                $Builder.ToString()
            }
            $quotedArguments = foreach ($Argument in $ArgumentList) {
                & $quoteArgument $Argument
            }

            $startProcessParams = @{
                FilePath               = $FilePath
                RedirectStandardError  = $stdErrTempFile
                RedirectStandardOutput = $stdOutTempFile
                PassThru               = $true
                NoNewWindow            = $true
            }
            if ($PSBoundParameters.ContainsKey("ArgumentList")) {
                $startProcessParams.ArgumentList = $quotedArguments -join " "
            }
            $cmd = Start-Process @startProcessParams
            # Retain the handle so Windows PowerShell 5.1 can read the exit code after the process exits.
            [void]$cmd.Handle

            $stopReason = $null
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            do {
                $exited = $cmd.WaitForExit(100)
                $capturedBytes = (Get-Item -LiteralPath $stdOutTempFile -ErrorAction "Stop").Length +
                    (Get-Item -LiteralPath $stdErrTempFile -ErrorAction "Stop").Length

                if ($capturedBytes -gt $MaximumOutputBytes) {
                    $stopReason = "Process '$FilePath' exceeded the output limit of $MaximumOutputBytes bytes."
                    break
                }
                if (-not $exited -and $stopwatch.Elapsed.TotalSeconds -ge $TimeoutSeconds) {
                    $stopReason = "Process '$FilePath' exceeded the timeout of $TimeoutSeconds seconds."
                    break
                }
            } until ($exited)

            if ($stopReason) {
                try {
                    if (-not $cmd.HasExited) { $cmd.Kill() }
                    $cmd.WaitForExit()
                }
                catch [System.InvalidOperationException] {
                    if (-not $cmd.HasExited) { throw }
                }
                throw $stopReason
            }

            $cmd.WaitForExit()
            $cmdOutput = Get-Content -LiteralPath $stdOutTempFile -Raw -ErrorAction "Stop"
            $cmdError = Get-Content -LiteralPath $stdErrTempFile -Raw -ErrorAction "Stop"
            if ($SuccessExitCodes -notcontains $cmd.ExitCode) {
                $detail = if ($cmdError) { $cmdError.Trim() } elseif ($cmdOutput) { $cmdOutput.Trim() } else { "No output captured." }
                throw "Process '$FilePath' exited with code $($cmd.ExitCode). $detail"
            }
            if ([System.String]::IsNullOrEmpty($cmdOutput) -eq $false) {
                Write-Output -InputObject $cmdOutput
            }
            if (-not [System.String]::IsNullOrWhiteSpace($cmdError)) {
                Write-Error -Message $cmdError.Trim() -ErrorAction "Continue"
            }
        }
    }
    catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
    finally {
        if ($cmd -and -not $cmd.HasExited) {
            try {
                $cmd.Kill()
                $cmd.WaitForExit()
            }
            catch {
                Write-Warning -Message "Unable to stop process '$FilePath' during cleanup: $($_.Exception.Message)"
            }
        }
        if ($cmd) { $cmd.Dispose() }

        foreach ($TempFile in $stdOutTempFile, $stdErrTempFile) {
            if ($TempFile -and (Test-Path -LiteralPath $TempFile -PathType "Leaf")) {
                try {
                    Remove-Item -LiteralPath $TempFile -Force -ErrorAction "Stop"
                }
                catch {
                    Write-Warning -Message "Unable to remove temporary process output file '$TempFile': $($_.Exception.Message)"
                }
            }
        }
    }
}
