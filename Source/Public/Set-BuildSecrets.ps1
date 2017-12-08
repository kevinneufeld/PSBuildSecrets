function Set-BuildSecrets {
    <#
    .SYNOPSIS
        Sets all secrets stored in a specific key vault as environment variables.
    .DESCRIPTION
        Sets all secrets stored in a specific key vault as environment variables. The user has to login to azure first using "Login-AzureRMAccount" 
    .PARAMETER KeyVaultName
        The name of the key vault containing the environment
    .PARAMETER SubscriptionID
            Allows the user to specify a subscription id if required. if not specified, the default subscription will be used.    
    .PARAMETER UseSecureString
        If specified the securestring version of the secrets will be stored in the environment.
    .EXAMPLE
        Set-BuildEnvironment -KeyVaultName "MyVault" -ResourceGroupName "MyResourceGroup"
    #>    
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String[]]$KeyVaultName,
        [Parameter(Mandatory = $false)]
        [String]$SubscriptionID,
        [Parameter(Mandatory = $false)]
        [Switch]$UseSecureString
    )    

       

    # Select the appropriate subscription
    if ($SubscriptionID) {
        Invoke-Azcli -Arguments "account set -s $SubscriptionID"
    }

    # Get all secrets from specified vault's
    foreach ($Name in $KeyVaultName) {

        Write-Verbose "Adding Secrets from Vault [$Name]"

        $Secrets = Invoke-Azcli -Arguments "keyvault secret list --vault-name $Name" | ForEach-Object { Split-Path $_.id -Leaf }          
        
        foreach ($Secret in $Secrets) {  
                    
            # We get the secret from azure key vault
            $SecretValue = Invoke-Azcli -Arguments "keyvault secret show --name $Secret --vault-name $Name" | Select-Object -ExpandProperty 'value'

            if ($UseSecureString) {
                # Set Environment Variable using clear text
                New-Item -Path Env:$Secret -Value (ConvertTo-SecureString -AsPlainText -Force -String $SecretValue ) -Force | Out-Null
            }
            else {
                # Set Environment Variable using secure string
                New-Item -Path Env:$Secret -Value $SecretValue -Force | Out-Null
            } 

            Write-Verbose "Secret [$Secret] added to environment"
        }

        # Store the secret names of the environment which is being loaded.
        if ($Script:Vaults -notcontains $Name) {
            $Script:Vaults += $Name  
        }
                      
        
    } 