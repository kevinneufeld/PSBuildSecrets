# Synopsis: Build the project.
Param(
    
)

# Synopsis: Bootstraps the build environment
task Bootstrap {
    
    # Invoke bootstrap in order to get PSDepend from artifactory.
    $BootstrapHelper = Join-Path $PSScriptRoot .\Invoke-Bootstrap.ps1
	.$BootstrapHelper

	# Import Workplace Build Helper Module (This module depends on it self)
	Import-Module $PSScriptRoot\..\Source\WorkplaceBuildHelper.psd1 -Force
    
    # Invoke PSDepend to download and load all dependencies
    Invoke-PSDepend -Force -Target $Env:SRBDependenciesFolderPath -Import -Install   
	        
    # Load Build Environment using BuildHelper Module function
	Set-BuildEnvironment -Force	

	# The test result NUnit target folder.
	Set-Item -Path ENV:SRBTestResultTargetPath -Value (Join-Path $ENV:SRBWorkingDirPath $ENV:SRBTestResultFolderName) -Force

	# Find the full path to the module manifest in the project folder
	Set-Item -Path ENV:SRBSourceRootPath -Value (Get-ChildItem $ENV:SRBProjectRoot -Directory $ENV:SRBSourceRootName).FullName -Force  
	Set-Item -Path ENV:SRBModuleManifest -Value (Get-ChildItem -Path $ENV:SRBSourceRootPath -Filter "*.psd1").FullName -Force

	# Find the module name
	Set-Item -Path ENV:SRBModuleName -Value (Get-Item -Path $ENV:SRBModuleManifest).BaseName -Force
	Set-Item -Path Env:SRBModuleRootPath -Value (Join-Path $ENV:SRBWorkingDirPath $ENV:SRBModuleName) -Force
	Set-Item -Path ENV:SRBRepositoryPath -Value (Join-Path $ENV:SRBWorkingDirPath $ENV:SRBRepositoryName) -Force

	# Variables for logging and testing
	Set-Item -Path ENV:SRBTimeStamp -Value (Get-Date -UFormat "%Y%m%d-%H%M%S")
	Set-Item -Path ENV:SRBPSVersion -Value $PSVersionTable.PSVersion.Major
	Set-Item -Path ENV:SRBTestFile -Value "TestResults_PS$PSVersion`_$TimeStamp.xml"
}

# Synopsis: Provision task for build automation.
task Build {

	try {		

		# We copy the source in to the working directory
		Write-Build -Color Green "Copy module root folder to match module name: from [$ENV:SRBSourceRootPath] to [$ENV:SRBModuleRootPath]"
		if (Test-Path -Path $ENV:SRBModuleRootPath -PathType Container) {
			Remove-Item -Recurse -Force -Path $ENV:SRBModuleRootPath
		}
		Copy-Item -Path $ENV:SRBSourceRootPath -Destination $ENV:SRBModuleRootPath -Force -Recurse
		
		# First we update the FunctionsToExport in the powershell module. This allows us to dot source the module functions and still autodiscover module cmdlets
		Write-Build -Color Green "Update FunctionsToExport in module manifest"
		Update-SRFunctionsToExport -ManifestPath (Get-ChildItem -Path $ENV:SRBModuleRootPath -Filter "*.psd1").FullName

		# We have to create a local folder for the local repository
		Write-Build -Color Green "Create folder for local staging repository: [$ENV:SRBRepositoryPath]"
		if (Test-Path -Path $ENV:SRBRepositoryPath) {
			Remove-Item -Recurse -Force -Path $ENV:SRBRepositoryPath
		}		
        New-Item -ItemType Directory -Path $ENV:SRBRepositoryPath | Out-Null
      
		Write-Build -Color Green "Register PSRepository with Source and Publish Location [$ENV:SRBRepositoryPath]"
		# First we unregister the repo if it is still registered.
		Get-PSRepository | Where-Object 'Name' -eq $ENV:SRBRepositoryName | Unregister-PSRepository 
		# Register Repostiory so we can publish the module to a local folder. This is required so we can use Bamboo to publish the module to artifactory.
        Register-PSRepository -Name $ENV:SRBRepositoryName -SourceLocation $ENV:SRBRepositoryPath -PublishLocation $ENV:SRBRepositoryPath -InstallationPolicy Trusted
            
		Write-Build -Color Green "Publish Module to PSRepository [$($ENV:SRBRepositoryName)]"
        Publish-Module -Path $ENV:SRBModuleRootPath -Repository $ENV:SRBRepositoryName -Verbose

    } catch {
        Throw "Error when bulding PowerShell module.`n$(Resolve-SRError)"
    }
   
}

# Synopsis: Runs test cases against the environment
task Test {

	# Create Results folder if required.
	if (-not (Test-Path -Path $ENV:SRBTestResultTargetPath -PathType Container)) { 
        New-Item -Path $ENV:SRBTestResultTargetPath -ItemType Directory -Force
    }

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $ENV:SRBProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile (Join-Path $ENV:SRBTestResultTargetPath $ENV:SRBTestFile)

    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Throw "Failed '$($TestResults.FailedCount)' tests, build failed"
    }

}

# Synopsis: Remove temporary files.
task Clean {

	Write-Build -Color Green "Unregister PSRepository [$($ENV:SRBRepositoryName)]"
	Get-PSRepository | Where-Object 'Name' -eq $ENV:SRBRepositoryName | Unregister-PSRepository 
    
}

# Synopsis: This is the default task which executes all tasks in order
task . Bootstrap, Test, Build, Clean


