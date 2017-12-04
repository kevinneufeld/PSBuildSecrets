$ModuleManifestName = 'PSBuildEnvironment.psd1'

Import-Module $PSScriptRoot\..\Source\$ModuleManifestName

Describe 'Module Manifest Tests' {

    It 'Passes Test-ModuleManifest' {

        Test-ModuleManifest -Path $PSScriptRoot\..\Source\$ModuleManifestName

        $? | Should Be $true

    }

    It 'Can be imported without throwing an exception' {
        
        {Import-Module $PSScriptRoot\..\Source\$ModuleManifestName } | Should not Throw
    }

}