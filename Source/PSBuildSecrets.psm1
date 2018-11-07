### DO NOT CHANGE THIS FILE (Only if you know what your doing... And you really have to :) 
$moduleRoot = Split-Path `
    -Path $MyInvocation.MyCommand.Path `
    -Parent

#region Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
#endregion

#region LocalizedData
$culture = 'en-us'
if (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath $PSUICulture))
{
    $culture = $PSUICulture
}

Import-LocalizedData `
    -BindingVariable LocalizedData `
    -Filename 'PSBuildSecrets.strings.psd1' `
    -BaseDirectory $moduleRoot `
    -UICulture $culture
#endregion

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        Write-Verbose -Message $($LocalizedData.ImportingFunctionMessage -f $import.Fullname)
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message $($LocalizedData.ImportingFucntionFailureMessage -f $import.Fullname, $_);
    }
}


# Export Public functions
Export-ModuleMember -Function $Public.Basename
