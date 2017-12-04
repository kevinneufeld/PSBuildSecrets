$ModuleManifest = ((Get-ChildItem -Path ..\Source\ -Filter '*.psd1').FullName)

Import-Module $ModuleManifest -Force

Describe 'Module Manifest Tests' {

    It 'Passes Test-ModuleManifest' {

        Test-ModuleManifest -Path $ModuleManifest

        $? | Should Be $true

    }

    It 'Can be imported without throwing an exception' {
        
        {Import-Module $ModuleManifest } | Should not Throw
    }

}