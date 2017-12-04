function Remove-BuildSecrets {
    <#
.SYNOPSIS
    Removes all variables of the current build environment
#>

    foreach ($Variable in $BuildSecrets) {
        Remove-Item -Path ENV:$Variable -Force
    }    

}