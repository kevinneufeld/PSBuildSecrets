# PSBuildEnvironment
This module uses Azure Key Vault to securely store environment variables and load them whenever and wherever needed.

# How to use

# Create a new key vault
```powershell
# Login to azure
Login-AzureRmAccount

# Create a new resource group for your environments (Or use an existing group)
New-AzureRmResourceGroup -Name 'BuildEnvironments' -Location northeurope

# Create the key vault
New-AzureRmKeyVault -VaultName 'staging' -ResourceGroupName 'BuildEnvironments' -Location 'northeurope'

# Set the secrets for your build environment

Set-AzureKeyVaultSecret -VaultName 'BuildEnvironments' -Name 'MySecret1' -SecretValue (ConvertTo-SecureString -String 'MySecretValue1' -AsPlainText -Force) -Tag @{ 'build-environment' = $EnvironmentName }

Set-AzureKeyVaultSecret -VaultName 'BuildEnvironments' -Name 'MySecret2' -SecretValue (ConvertTo-SecureString -String 'MySecretValue2' -AsPlainText -Force) -Tag @{ 'build-environment' = $EnvironmentName }

# Create the key vault
New-AzureRmKeyVault -VaultName 'prod' -ResourceGroupName 'BuildEnvironments' -Location 'northeurope'

Set-AzureKeyVaultSecret -VaultName 'BuildEnvironments' -Name 'MySecret1' -SecretValue (ConvertTo-SecureString -String 'MySecretValue1' -AsPlainText -Force) -Tag @{ 'build-environment' = $EnvironmentName }

Set-AzureKeyVaultSecret -VaultName 'BuildEnvironments' -Name 'MySecret2' -SecretValue (ConvertTo-SecureString -String 'MySecretValue2' -AsPlainText -Force) -Tag @{ 'build-environment' = $EnvironmentName }


```

## ToDo
- Remove dependency on AzureRM (Cross Platform support)
- Add Tag support for multi environment support per key vault

## Credits

Thanks to Daniel Scott-Raynsford for his excelent post on how to use [Azure Key Vault with Powershell](https://dscottraynsford.wordpress.com/2017/04/17/using-azure-key-vault-with-powershell-part-1/)
