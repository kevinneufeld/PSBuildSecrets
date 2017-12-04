function Get-BuildSecrets {
    <#
.SYNOPSIS
    Gets all variables which are currently set
.PARAMETER KeyVaultName
    The name if the key vault 
#>
param (
    [Parameter(Mandatory=$false)]
    [Switch]$KeyVaultName
)

    # This would set all secrets of a vault as environment variables. 
    $Secrets = Get-AzureKeyVaultSecret -VaultName $KeyVaultName | Select-Object -ExpandProperty Name   

    foreach ($Secret in $Secrets) {      
      

        # Set Environment Variable
        New-Item -Path Env:$Secret -Value $SecretValue.SecretValueText -Force
    }


    if ($ListValues) {
        foreach ($Variable in $BuildSecrets) {
            Get-Item -Path ENV:$Variable
        }
    }
    else {
        Write-Output $BuildSecrets
    }

   
}