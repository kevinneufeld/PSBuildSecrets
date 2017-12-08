function Get-BuildSecrets {
    <#
.SYNOPSIS
    Gets all secrets in the current environment
.PARAMETER KeyVaultName
    The name of the key vault containing the environment
.PARAMETER ShowValue
    If specified the secret value will be written to the console
.PARAMETER SubscriptionID
    Allows the user to specify a subscription id if required. if not specified, the default subscription will be used.
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 1)]
        [String[]]$KeyVaultName,
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [Switch]$ShowValue,
        [Parameter(Mandatory = $false)]
        [String]$SubscriptionID
    )

    # Select the appropriate subscription
    if ($SubscriptionID) {
        Invoke-Azcli -Arguments "account set -s $SubscriptionID"
    }

    # If no key vault is specified, we just list the vaults already loaded
    if (-not $KeyVaultName) {
        $KeyVaultName = $Script:Vaults
    }

    foreach ($Name in $KeyVaultName) { 
        
        $Secrets = Invoke-Azcli -Arguments "keyvault secret list --vault-name $Name" | ForEach-Object { Split-Path $_.id -Leaf }          

        foreach ($Secret in $Secrets) { 

            $var = Get-Item -Path Env:$Secret -ErrorAction SilentlyContinue

            if ($var) {
                if ($ShowValue) {
                    # Set Environment Variable
                    Get-Item -Path Env:$Secret
                } else {
                    Write-Output $Secret
                }
               
            } else {
                Write-Output "Could not find secret [$Secret] in current environment"
            }
 
        }
    }
   
}