function Set-BuildSecrets {
    <#
    .SYNOPSIS
        Sets all secrets stored in a specific key vault as environment variables.
    .DESCRIPTION
        Sets all secrets stored in a specific key vault as environment variables. The user has to login to azure first using "az login"

        Important: The - character will automatically be replaced with the _ character.
    .PARAMETER KeyVaultName
        The name of the key vault containing the environment
    .PARAMETER SecretName
        If specified only the value of the secret with the specified name will be set.
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
        [String]$SecretName,
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

    # Get all secrets from specified vault's
    foreach ($Name in $KeyVaultName) {

        $Results = Invoke-Azcli -ArgumentList "keyvault show --name $Name"

        if ($Results.name -ne $Name) {
            throw "Key vault [$name] does not exists."
        }

        Write-Verbose "Adding Secrets from Vault [$Name]"       

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
                    
            # We get the secret from azure key vault
            $SecretValue = Invoke-Azcli -ArgumentList "keyvault secret show --name $Secret --vault-name $Name" | Select-Object -ExpandProperty 'value'

            # Replace - with _
            $Secret = $($Secret.Replace('-','_'))

            # Set Environment Variable 
            New-Item -Path Env:$Secret -Value $SecretValue -Force | Out-Null            

            Write-Verbose "Secret [$($Secret.Replace('-','_'))] added to environment"
        }

        Write-Output "[$($Secrets.Count)] secrets added to environment"
        
    } 

}