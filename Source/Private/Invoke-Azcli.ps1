function Invoke-Azcli {
    <#
    .SYNOPSIS
        This function is a wrapper for azure cli
    .PARAMETER Arguments
        The arguments to be passed on to az
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,Position=1)]
        [String]$Arguments
    )

    $Output = Invoke-Expression -Command "az $Arguments"

    try {
        # Lets try to convert the json output
        Write-Output (ConvertFrom-Json -InputObject (-join $Output))
    } catch {
        # If we cant parse it, just write the output to the pipeline
        Write-Output $Output
    }

}