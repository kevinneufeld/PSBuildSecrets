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
        [Parameter(Mandatory = $true, Position = 1)]
        [String[]]$KeyVaultName,
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [Switch]$ShowValue,
        [Parameter(Mandatory = $false)]
        [String]$SubscriptionID
    )

   # Check if we are logged in
   $Results = Invoke-Azcli -Arguments "account list"
   
   if ($Results.Count -lt 1) {
       throw "You must login first"    
   }

   # Select the appropriate subscription
   if ($SubscriptionID) {
       Invoke-Azcli -Arguments "account set -s $SubscriptionID"
   }

   $Results = Invoke-Azcli -Arguments "account show"

   if ($Results.state -ne 'Enabled') {
       throw "You must select a subscription"    
   }

    foreach ($Name in $KeyVaultName) { 
        $Results = Invoke-Azcli -Arguments "keyvault show --name $Name"
        
        if ($Results.name -ne $Name) {
            throw "Key vault [$name] does not exists."
        }

        Write-Verbose "Getting Secrets from Vault [$Name]"       

        $Results = Invoke-Azcli -Arguments "keyvault secret list --vault-name $Name"

        if ($Results.Count -lt 1) {
            Write-Verbose "No secrets found in vault [$Name]"
        }

        $Results = Invoke-Azcli -Arguments "keyvault secret list --vault-name $Name"
        
        $Secrets = @()

        foreach ($Result in $Results) {
            $Secrets += Split-Path $Result.id -Leaf
        }       
        
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