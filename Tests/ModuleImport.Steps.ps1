BeforeEachFeature {
    
    $Script:ModuleName = "PSBuildSecrets"

    $Script:ModuleManifestPath = Join-Path "$($PSScriptRoot)\..\Source\" "$ModuleName.psd1"
}

Given 'the module manifest exists' {
    $ModuleManifestPath | Should Exist
}

Given 'the module manifest is valid' {
    Test-ModuleManifest -Path $ModuleManifestPath | Should Be $true
}

When 'we try to import the module' {
    {Import-Module $ModuleManifestPath }| Should Not Throw
}

Then 'the module is loaded without any exceptions' {
    Get-Module -Name $ModuleName | Should Not Be $false
}


