function Get-BuildSecrets {
    <#
.SYNOPSIS
    Gets all secrets in the current environment
.PARAMETER KeyVaultName
    The name of the key vault containing the environment
.PARAMETER SubscriptionID
    Allows the user to specify a subscription id if required. if not specified, the default subscription will be used.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false,Position=1)]
    [String[]]$KeyVaultName,
    [Parameter(Mandatory=$false)]
    [String]$SubscriptionID
)

    # Select the appropriate subscription
    if ($SubscriptionID) {
        Select-AzureRmSubscription -SubscriptionId $SubscriptionID 
    }

    # Get all secrets from specified vault's
    $Secrets = @()

    # If no key vault is specified, we just list the vaults already loaded
    if (-not $KeyVaultName) {
        $KeyVaultName = $Script:Vaults
    }

    foreach ($Name in $KeyVaultName) { 
        $Secrets += Get-AzureKeyVaultSecret -VaultName $KeyVaultName | Select-Object -ExpandProperty Name           
    }

    foreach ($Secret in $Secrets) { 

        try {
            # Set Environment Variable
            Get-Item -Path Env:$Secret 
        } catch {
            Write-Output "Could not find secret [$Secret] in current environment"
        }
 
    }
   
}