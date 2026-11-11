function Assert-VcSignature {
    <#
        .SYNOPSIS
            Throws unless a file has a valid Authenticode signature from the expected publisher.
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $Path,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String] $SignerSubject = (Get-VcConfig).Download.SignerSubject
    )

    $Signature = Get-AuthenticodeSignature -LiteralPath $Path -ErrorAction "Stop"
    if ($Signature.Status -ne "Valid") {
        throw "Authenticode signature on '$Path' is not valid: $($Signature.Status)."
    }
    $Subject = $Signature.SignerCertificate.Subject
    if ($Subject -notmatch "(^|,\s*)CN=`"?$([System.Text.RegularExpressions.Regex]::Escape($SignerSubject))`"?(,|$)") {
        throw "'$Path' is not signed by '$SignerSubject'. Signer: $Subject."
    }
    $true
}
