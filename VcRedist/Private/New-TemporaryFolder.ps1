function New-TemporaryFolder {
    <#
        .SYNOPSIS
            Creates a new temporary folder

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.String])]
    param ()

    $Folder = "vcredist_$([System.Guid]::NewGuid().ToString('N')).tmp"
    $T = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath $Folder
    if ($PSCmdlet.ShouldProcess($T, "New directory.")) {
        $Path = New-Item -Path $T -ItemType "Directory" -ErrorAction "Stop"
        Write-Output -InputObject $Path.FullName
    }
}
