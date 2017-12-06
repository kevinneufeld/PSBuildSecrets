function Remove-BuildSecrets {
    <#
.SYNOPSIS
    Removes all variables from the specified key vault from the current environment
.PARAMETER KeyVaultName
    The name of the key vault containing the environment
.PARAMETER SubscriptionID
        Allows the user to specify a subscription id if required. if not specified, the default subscription will be used.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true,Position=1)]
    [String]$KeyVaultName,
    [Parameter(Mandatory=$false)]
    [String]$SubscriptionID
)

    # Select the appropriate subscription
    if ($SubscriptionID) {
        Select-AzureRmSubscription -SubscriptionId $SubscriptionID 
    }

      # Get all secrets from the specified key vault 
    $Secrets = Get-AzureKeyVaultSecret -VaultName $KeyVaultName | Select-Object -ExpandProperty Name   

    foreach ($Secret in $Secrets) { 

        try { 
            # Set Environment Variable
            Get-Item -Path Env:$Secret 
        } catch {
            Write-Output "Could not find secret [$Secret] in current environment"
        }
 
    }   

}