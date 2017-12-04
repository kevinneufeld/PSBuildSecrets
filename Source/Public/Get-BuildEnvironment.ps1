function Get-BuildEnvironment {
    <#
.SYNOPSIS
    Gets all variables which are currently set
#>
param (
    [Parameter(Mandatory=$false)]
    [Switch]$ListValues
)

    if ($ListValues) {
        foreach ($Variable in $BuildEnvironment) {
            Get-Item -Path ENV:$Variable
        }
    }
    else {
        Write-Output $BuildEnvironment
    }

   
}