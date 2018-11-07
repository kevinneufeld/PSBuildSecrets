$scriptRoot = Split-Path $MyInvocation.MyCommand.Path
$tmp_path = Join-path -path $scriptRoot -ChildPath "..\..\Source\Private\helperfunctions.ps1"
. $tmp_path -Verbose

Describe "Unit testing of all helper functions" {

    It "Return username and password from Credentials object" {
        $uid,$pswd = "lesgrossman","1234567890"
        $creds = (New-Object System.Management.Automation.PSCredential( $uid, ($pswd | ConvertTo-SecureString -AsPlainText -Force)));
        (Get-CredentialData -Credential $creds) | should -be $uid,$pswd; 
    }

    It "Return password from secure string" {
        $pswd = "1234567890"
        (($pswd | ConvertTo-SecureString -AsPlainText -Force) | Get-PasswordFromSecureString ) | should -be $pswd;
    }
}