function Set-BuildSecrets {
    <#
    .SYNOPSIS
        Sets all secrets stored in a specific key vault as environment variables.
    .DESCRIPTION
        Sets all secrets stored in a specific key vault as environment variables. The user has to login to azure first using "az login"

        Important: The - character will automatically be replaced with the _ character.
    .PARAMETER KeyVaultName
        The name of the key vault containing the environment
    .PARAMETER SubscriptionID
            Allows the user to specify a subscription id if required. if not specified, the default subscription will be used.    
    .EXAMPLE
        Set-BuildEnvironment -KeyVaultName "MyVault" -ResourceGroupName "MyResourceGroup"
    #>    
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String[]]$KeyVaultName,
        [Parameter(Mandatory = $false)]
        [String]$SubscriptionID
    )           

    # Select the appropriate subscription
    if ($SubscriptionID) {
        Invoke-Azcli -Arguments "account set -s $SubscriptionID"
    }

    $Results = Invoke-Azcli -Arguments "account show"

    if ($Results.state -ne 'Enabled') {
        throw "You must login and select a subscription"   
    }

    # Get all secrets from specified vault's
    foreach ($Name in $KeyVaultName) {

        $Results = Invoke-Azcli -Arguments "keyvault show --name $Name"

        if ($Results.name -ne $Name) {
            throw "Key vault [$name] does not exists."
        }

        Write-Verbose "Adding Secrets from Vault [$Name]"       

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
                    
            # We get the secret from azure key vault
            $SecretValue = Invoke-Azcli -Arguments "keyvault secret show --name $Secret --vault-name $Name" | Select-Object -ExpandProperty 'value'

            # Replace - with _
            $Secret = $($Secret.Replace('-','_'))

            # Set Environment Variable 
            New-Item -Path Env:$Secret -Value $SecretValue -Force | Out-Null            

            Write-Verbose "Secret [$($Secret.Replace('-','_'))] added to environment"
        }        
        
    } 

}