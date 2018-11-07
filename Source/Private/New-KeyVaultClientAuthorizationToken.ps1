function New-KeyVaultClientAuthorizationToken() {
    
    [cmdletbinding(DefaultParameterSetName='Client')]
    [OutputType([System.String])]
    param(
        [Parameter(mandatory = $true)]
        [string]$TenantId,
        [Parameter(mandatory = $false)]
        [string]$AzureResource = "https://vault.azure.net",
        [Parameter(ParameterSetName='Client', mandatory = $true)]
        [string]$ClientId,
        [Parameter(ParameterSetName='Client',mandatory = $true)]
        [securestring]$ClientSecret,
        [Parameter(ParameterSetName='PSCreds',mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SPCredential = $null

    )

    Write-Verbose -Message $($LocalizedData.CreateAuthorizationToken -f $Method, $ResourceType, $ResourceId, $Date)
    $uri = Get-AzureAuthorizationUri -TenantId $TenantId;
        
    if($SPCredential){
        $creds = $SPCredential;    
    }else{
        $creds = (New-Object System.Management.Automation.PSCredential ($ClientId, $ClientSecret))
    }
    $creds_hash = @{
        grant_type    = "client_credentials"
        client_id     = $creds.GetNetworkCredential().UserName
        client_secret = $creds.GetNetworkCredential().Password
        resource      = $AzureResource
    };
    try{
        $response = Invoke-RestMethod -uri $uri -Method Post -Body $creds_hash -Headers $null -ContentType application/x-www-form-urlencoded;
        return $response.access_token;
    }catch{
        Throw $($LocalizedData.AuthorizationTokenFailed);
    }
    
}
