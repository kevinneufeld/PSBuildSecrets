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
        [Parameter(Mandatory=$true)]
        [String]$KeyVaultName,
        [Parameter(Mandatory=$false)]
        [String]$SubscriptionID,
        [Parameter(Mandatory=$false)]
        [Switch]$UseSecureString
    )
    

    Begin {
        
    }
    Process {

        try {         
                     
            # This would set all secrets of a vault as environment variables. 
            $Secrets = Get-AzureKeyVaultSecret -VaultName $KeyVaultName | Where-Object -Property Tags -In $Tag | Select-Object -ExpandProperty Name           
                       
            foreach ($Secret in $Secrets) {  
        
                # We get the secret from azure key vault
                $SecretValue = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $Secret

               if ($UseSecureString) {
                    # Set Environment Variable using secure string
                    New-Item -Path Env:$Secret -Value $SecretValue.SecretValue -Force
               } else {
                    # Set Environment Variable using clear text
                    New-Item -Path Env:$Secret -Value $SecretValue.SecretValueText -Force
               }    

            }

             # Store the secret names of the environment which is being loaded.
             $Script:BuildEnvironment += $KeyVaultName

        } Catch {              
            Throw "$($_.Exception.Message)"
        }
  
    }
    End {
    
    }

} 