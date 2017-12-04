function Remove-BuildEnvironment {
    <#
.SYNOPSIS
    Removes all variables of the current build environment
#>

    foreach ($Variable in $BuildEnvironment) {
        Remove-Item -Path ENV:$Variable -Force
    }    

}