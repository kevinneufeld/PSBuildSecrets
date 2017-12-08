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
        [Parameter(Mandatory = $true, Position = 1)]
        [String[]]$KeyVaultName,
        [Parameter(Mandatory = $false)]
        [String]$SubscriptionID
    )

    # Select the appropriate subscription
    if ($SubscriptionID) {
        Invoke-Azcli -Arguments "account set -s $SubscriptionID"
    }

    # Get all secrets from specified vault's
    $Secrets = @()
    
    foreach ($Name in $KeyVaultName) { 
       
        $Secrets = Invoke-Azcli -Arguments "keyvault secret list --vault-name $Name" | ForEach-Object { Split-Path $_.id -Leaf }  
   
        foreach ($Secret in $Secrets) { 

            $var = Get-Item -Path Env:$Secret -ErrorAction SilentlyContinue
            
            if ($var) {
                # Set Environment Variable
                Remove-Item -Path Env:$Secret
            } else {
                Write-Output "Could not find secret [$Secret] in current environment"
            }
 
        }

        # Remove vault from list of loaded vaults
        if ($Script:Vaults -contains $Name) {
            $Script:Vaults.Remove($Name)
        }
        
    
    }

}