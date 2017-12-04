 function Set-SRVariablesFromJson {
    <#
    .SYNOPSIS
        Reads a json file and sets environment variables.
    .DESCRIPTION
        Reads a Json file and sets all key value pairs in the root element of the file as environment variables
    .PARAMETER Path 
        The Path to the JSON file to be parsed.
    .PARAMETER Prefix
        Specifies a prefix for the variables, default is ''
    .EXAMPLE
        Set-SRVariablesFromJson -Path C:\Temp\Variables.json
    #>       
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, Position=1)]
        [String]$Path,
        [Parameter(Mandatory=$false, Position=2)]
        [String]$Prefix=""
    )

    try {

        $VariablesJson = ConvertFrom-Json -InputObject (Get-Content -Path $Path -Raw)

        $VariableProperties = Get-Member -InputObject $VariablesJson -Type NoteProperty
    
        foreach ($VariableProperty in $VariableProperties) {                
                New-Item -Path Env:$Prefix$($VariableProperty.Name) -Value $($VariablesJson.$($VariableProperty.Name)) -Force
        }

    } Catch {
            Write-Error "Can't set variables from JSON file `n$($_)"
            Throw "$($_.Exception.Message)"

    }
}
  
 function Get-PSDepend {
    
     Param(
         [Parameter(Mandatory=$true, Position=1)]
         [String]$Target
     )
 
     try {
 
     # Download and Load the PSDepend Module
         Save-Module -Name PSDepend -Path $Target
         Import-Module (Join-Path $Target PSDepend)
     
 
     } Catch {
             Write-Error "Can't get PSDepend `n$($_)"
             Throw "$($_.Exception.Message)"
 
     }
 }


# Sets some environment variables required for the build.
New-Item -Path Env:SRBBuildRoot -Value $PSScriptRoot -Force
New-Item -Path Env:SRBProjectRoot -Value $((Get-Item $PSScriptRoot).Parent.FullName) -Force  

Set-SRVariablesFromJson -Path (Join-Path $Env:SRBBuildRoot 'variables.json')

New-Item -Path Env:SRBWorkingDirPath -Value (Join-Path $Env:SRBProjectRoot $ENV:SRBWorkingDir) -Force          

# Create Dependency Target Path for dependency download
New-Item -Path Env:SRBDependenciesFolderPath -Value (Join-Path $ENV:SRBWorkingDirPath $ENV:SRBDependenciesFolderName) -Force

if (-not (Test-Path -PathType Container -Path $ENV:SRBWorkingDirPath)) {
    New-Item -Path $Env:SRBWorkingDirPath -ItemType Container -Force               
}

# Create Dependencies folder
if (-not (Test-Path -PathType Container -Path $Env:SRBDependenciesFolderPath)) {
    New-Item -Path $Env:SRBDependenciesFolderPath -ItemType Container -Force               
}
    
# Installs and Loads PSDepend
Get-PSDepend -Target $Env:SRBDependenciesFolderPath