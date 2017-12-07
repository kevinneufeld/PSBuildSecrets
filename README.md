# PSBuildSecrets
This module uses Azure Key Vault to securely store secrets and allows you to set them as encironment variables using a single command.

[![Build status](https://ci.appveyor.com/api/projects/status/o2q8w3iqi58ouuwy?svg=true)](https://ci.appveyor.com/project/synax/psbuildsecrets)


# How to use

## Install Modules
First we need to install all required modules:
```Powershell
    # Open an elevated powershell prompt (you could also install it in user scope)
    Install-Module PSBuildSecrets,AzureRM
```

## Setup Secrets in Azure
First you need to create a key vault in azure and store some secrets. The following example shows how to create two key vaults, one called "prod" the other one "staging".

```powershell
# Login to azure
Login-AzureRmAccount

# Create a new resource group for your build secrets (Or use an existing group)
New-AzureRmResourceGroup -Name 'BuildSecrets' -Location northeurope

# Create the key vault for staging
$EnvironmentName = 'prod'

New-AzureRmKeyVault -VaultName $EnvironmentName -ResourceGroupName 'BuildSecrets' -Location 'northeurope'

# Set the secrets for the staging build environment
Set-AzureKeyVaultSecret -VaultName 'BuildSecrets' -Name 'MySecret1' -SecretValue (ConvertTo-SecureString -String 'MySecretValue1' -AsPlainText -Force) -Tag @{ 'build-environment' = $EnvironmentName }

Set-AzureKeyVaultSecret -VaultName 'BuildSecrets' -Name 'MySecret2' -SecretValue (ConvertTo-SecureString -String 'MySecretValue2' -AsPlainText -Force) -Tag @{ 'build-environment' = $EnvironmentName }

# Create the key vault fpr prod
$EnvironmentName = 'prod'

New-AzureRmKeyVault -VaultName $EnvironmentName -ResourceGroupName 'BuildSecrets' -Location 'northeurope'

# Set the secrets for the prod build environment
Set-AzureKeyVaultSecret -VaultName 'BuildSecrets' -Name 'MySecret1' -SecretValue (ConvertTo-SecureString -String 'MySecretValue1' -AsPlainText -Force) -Tag @{ 'build-environment' = $EnvironmentName }

Set-AzureKeyVaultSecret -VaultName 'BuildSecrets' -Name 'MySecret2' -SecretValue (ConvertTo-SecureString -String 'MySecretValue2' -AsPlainText -Force) -Tag @{ 'build-environment' = $EnvironmentName }


```

## ToDo
- Use Powershell Core and remove dependency on AzureRM (Cross Platform support)

## Credits

Thanks to Daniel Scott-Raynsford for his excelent post on how to use [Azure Key Vault with Powershell](https://dscottraynsford.wordpress.com/2017/04/17/using-azure-key-vault-with-powershell-part-1/)
