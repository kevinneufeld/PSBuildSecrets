
function Invoke-Azcli {
    <#
    .SYNOPSIS
        This function is a wrapper for azure cli
    .PARAMETER ArgumentList
        The arguments to be passed on to az
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,Position=1)]
        [String[]]$ArgumentList
    )

    $CommandPath = Get-Command -Name az | Select-Object -First 1 -ExpandProperty Source

    # Invoke azure cli and process result
     $Result = Invoke-Process -Path $CommandPath @PSBoundParameters

     if ($Result.ExitCode -ne 0) {
          throw "StdErr: $($Result.StdErr)`nStdOut: $($Result.StdOut)`nExitCode: $($Result.ExitCode)"
     } 

    try {
        # Lets try to convert the json output
        Write-Output (ConvertFrom-Json -InputObject (-join $Result.StdOut))
    } catch {
        "StdErr: $($Result.StdErr) $($_)`nStdOut: $($Result.StdOut)`nExitCode: $($Result.ExitCode)"

        # If we cant parse it, just write the output to the pipeline
        Write-Output $Result.StdOut
    }

}
