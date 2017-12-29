function Get-BuildSecrets {
    <#
.SYNOPSIS
    Gets all secrets currently set in the environment
.DESCRIPTION
    Gets all secrets currently set in the environment. The user has to login to azure first using "az login"

    Important: The - character will automatically be replaced with the _ character.
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
        [Parameter(Mandatory = $false)]
        [String]$SecretName,
        [Parameter(Mandatory=$false)]
        [Alias('s')]
        [Switch]$ShowValue,
        [Parameter(Mandatory = $false)]
        [String]$SubscriptionID
    )

      # Select the appropriate subscription
      if ($SubscriptionID) {
        Invoke-Azcli -ArgumentList "account set -s $SubscriptionID"
    }

    $Results = Invoke-Azcli -ArgumentList "account show"

    if ($Results.state -ne 'Enabled') {
        throw "You must login and select a subscription"   
    }

    foreach ($Name in $KeyVaultName) { 
        $Results = Invoke-Azcli -ArgumentList "keyvault show --name $Name"
        
        if ($Results.name -ne $Name) {
            throw "Key vault [$name] does not exists."
        }

        Write-Verbose "Getting Secrets from Vault [$Name]"       

        $QueryString = "keyvault secret list --vault-name $Name"

        if ($SecretName) {
            # We replace all underscores with a dash... just in case somebody wants to reference the variable name rather than the secret name...
            $QueryString += ' --query "[?contains(id, `{0}`)]"' -f $($SecretName.Replace('_','-'))
        }

        $Results = Invoke-Azcli -ArgumentList $QueryString

        if ($Results.Count -lt 1) {
            Write-Verbose "No secrets found in vault [$Name]"
        }
        
        $Secrets = @()

        foreach ($Result in $Results) {
            $Secrets += Split-Path $Result.id -Leaf
        }       
        
        foreach ($Secret in $Secrets) {  

            # Replace - with _
            $Secret = $($Secret.Replace('-','_'))

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