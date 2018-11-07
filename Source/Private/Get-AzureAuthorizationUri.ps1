function Get-AzureAuthorizationUri
{

    [CmdletBinding()]
    [OutputType([uri])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $BaseUri = 'login.microsoftonline.com'
    )

    return [uri]::new(('https://{0}/{1}/oauth2/token' -f  $BaseUri,$TenantId))
}