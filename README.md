# PSBuildSecrets
This module uses Azure Key Vault to securely store secrets and allows you to set them as environment variables using a single command.

[![Build status](https://ci.appveyor.com/api/projects/status/o2q8w3iqi58ouuwy?svg=true)](https://ci.appveyor.com/project/synax/psbuildsecrets)


# How to use
This module uses azure cli to interact with azure. It's a very straight forward and fully supported way to interact with azure. It also makes this work cross platform!

## Requirements
PSBuildSecrets has the following requirements:
- Powershell 5.1 / 6.0.0-rc
    - [How to get Powershell](https://github.com/PowerShell/PowerShell)
- Azure CLI 2.0 +
    - [How to get Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## How to use
All commands are executed in a PowerShell session.
### Setup Key Vault

```Powershell

# Login to azure
az login

# Create a new resource group for your build secrets (Or use an existing group)
az group create -n 'BuildSecrets' -l 'northeurope'

# Register the keyvault prvovider if not already done
az provider register Microsoft.KeyVault

# Create the key vault for staging
az keyvault create -n 'project1' -g 'BuildSecrets' -l 'northeurope'

# Set the secrets for the staging build environment

# IMPORTANT: The - character in the variable name will automatically be replaced with the _ character 
#            when set in a environent as environment variable. my-secret-1 would be my_secret_1.
az keyvault secret set --vault-name 'project1' --name 'my-secret-1' --value 'mysecretvalue'
az keyvault secret set --vault-name 'project1' --name 'my-secret-2' --value 'mysecretvalue'

# Create the key vault for staging
az keyvault create -n 'project2' -g 'BuildSecrets' -l 'northeurope'

# Set the secrets for the staging build environment
az keyvault secret set --vault-name 'project2' --name 'my-secret-3' --value 'mysecretvalue'
az keyvault secret set --vault-name 'project2' --name 'my-secret-4' --value 'mysecretvalue'
az keyvault secret set --vault-name 'project2' --name 'my-secret-5' --value 'mysecretvalue'
az keyvault secret set --vault-name 'project2' --name 'my-secret-6' --value 'mysecretvalue'

# Note: The secret names accross projects should be unique if you want to load them at the same time. If there is a variable with the same name in two different vaults, as of today, the environment you load last, wins :)

```

### Set Build Secrets

```Powershell

# Install the PSBuildSecrets Module
Import-Module BuildSecrets

# Set Build Secrets for myenvironment-prod
Set-BuildSecrets 'project1','project2' -Verbose

VERBOSE: Adding Secrets from Vault [project1]
VERBOSE: Secret [my_secret_1] added to environment
VERBOSE: Secret [my_secret_2] added to environment
VERBOSE: Adding Secrets from Vault [project2]
VERBOSE: Secret [my_secret_1] added to environment
VERBOSE: Secret [my_secret_2] added to environment
VERBOSE: Secret [my_secret_3] added to environment
VERBOSE: Secret [my_secret_4] added to environment
VERBOSE: Secret [my_secret_5] added to environment
VERBOSE: Secret [my_secret_6] added to environment
```

### Get Buils Secrets

```Powershell

# Get all build secrets in the environment
Get-BuildSecrets

my_secret_1
my_secret_2
my_secret_3
my_secret_4
my_secret_5
my_secret_6


# Get all build secrets in the environment and show values
Get-BuildSecrets -s

Name                           Value
----                           -----
my_secret_1                    mysecretvalue
my_secret_2                    mysecretvalue
my_secret_3                    mysecretvalue
my_secret_4                    mysecretvalue
my_secret_5                    mysecretvalue
my_secret_6                    mysecretvalue

# Show secrets from project 1
Get-BuildSecrets 'project1'

Name                           Value
----                           -----
my_secret_1                    mysecretvalue
my_secret_2                    mysecretvalue

```
### Remove Build Secrets
```Powershell
# remove project 1
Remove-BuildSecrets 'project1'

# Check the environment
Get-BuildSecrets -s

Name                           Value
----                           -----
my_secret_3                    mysecretvalue
my_secret_4                    mysecretvalue
my_secret_5                    mysecretvalue
my_secret_6                    mysecretvalue

```

## ToDo
- Add support for certificates and keys
- Add usage examples to help
- Add support for other backends using providers
- Improve exception handling

## Credits

Thanks to Daniel Scott-Raynsford for his excelent post on how to use [Azure Key Vault with Powershell](https://dscottraynsford.wordpress.com/2017/04/17/using-azure-key-vault-with-powershell-part-1/)
