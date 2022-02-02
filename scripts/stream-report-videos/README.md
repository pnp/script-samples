---
plugin: add-to-gallery
---
     
# Export a csv report on all Microsoft Stream videos

![Outputs](assets/header.png)

## Summary

Export a report on all Microsoft Stream (Classic) videos (build on SharePoint)
  
Microsoft Stream (Classic) will be retired soon , therefore we need to gather a list of all videos info for a mid-term migration   
This script allow us to export a list with all videos detailed in our tenant .


The script is a subset of the SPO PowerShell packages with content (PnPCandy) concept already been used across many projects.  


Excelsior, hum? :P  

# [PnP PowerShell](#tab/pnpps)

```powershell

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)] 
    [string]$OutputCsvFileName,

    [parameter(Position=1,Mandatory=$False)] 
    [switch]$OpenFileWhenComplete = $False
)


# ----------------------------------------------------------------------------------------------
function Show-OAuthWindowStream {
    param (
        [string]$Url,
        [string]$WindowTitle
    )
       
    $Source = `
@"
    [DllImport("wininet.dll", SetLastError = true)]
    public static extern bool InternetSetOption(IntPtr hInternet, int dwOption, IntPtr lpBuffer, int lpdwBufferLength);
"@

    $WebBrowser = Add-Type -memberDefinition $Source -passthru -name $('WebBrowser'+[guid]::newGuid().ToString('n'))
    $INTERNET_OPTION_END_BROWSER_SESSION = 42
    # Clear the current session
    $WebBrowser::InternetSetOption([IntPtr]::Zero, $INTERNET_OPTION_END_BROWSER_SESSION, [IntPtr]::Zero, 0) | out-null

    Add-Type -AssemblyName System.Windows.Forms
    $Form = New-Object -TypeName System.Windows.Forms.Form -Property @{Width = 600; Height = 800 }

    $Script:web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{Width = 580; Height = 780; Url = ($URL -f ($Scope -join "%20")) }
    $Web.ScriptErrorsSuppressed = $True
    $Form.Controls.Add($Web)
    $Featured = {
        $Head = $Web.Document.GetElementsByTagName("head")[0];
        $ScriptEl = $Web.Document.CreateElement("script");
        $Element = $ScriptEl.DomElement;

        # Javascript function to get the sessionInfo including the Token
        $Element.text = `
@'
        function CaptureToken() { 
            if( typeof sessionInfo === undefined ) {
                return '';
            } else {
                outputString = '{';
                outputString += '"AccessToken":"' + sessionInfo.AccessToken + '",';
                outputString += '"TenantId":"' + sessionInfo.UserClaim.TenantId + '",';
                outputString += '"ApiGatewayUri":"' + sessionInfo.ApiGatewayUri + '",';
                outputString += '"ApiGatewayVersion":"' + sessionInfo.ApiGatewayVersion + '"';
                outputString += '}';

                return outputString;
            }
        }
'@;

        $Head.AppendChild($ScriptEl);
        $TenantInfoString = $Web.Document.InvokeScript("CaptureToken");
            
        if( [string]::IsNullOrEmpty( $TenantInfoString ) -eq $False ) {
            $TenantInfo = ConvertFrom-Json $TenantInfoString
            if ($TenantInfo.AccessToken.length -ne 0 ) {
                $Script:tenantInfo = $TenantInfo;
                $Form.Controls[0].Dispose()
                $Form.Close()
                $Form.Dispose()
            }
        }

    }
    $Web.add_DocumentCompleted($Featured)
    $Form.AutoScaleMode = 'Dpi'
    $Form.ShowIcon = $False
    $Form.Text = $WindowTitle
    $Form.AutoSizeMode = 'GrowAndShrink'
    $Form.StartPosition = 'CenterScreen'
    $Form.Add_Shown( { $Form.Activate() })
    $Form.ShowDialog() | Out-Null

    write-output $Script:tenantInfo
}

# ----------------------------------------------------------------------------------------------
function Get-RequestedAssets([PSCustomObject]$Token, [string]$Url, [string]$Label) {
    $Index = 0
    $MainUrl = $Url
    $AllItems = @()
    do {
        $RestUrl = $MainUrl.Replace("`$skip=0", "`$skip=$Index") 
            
        Write-Host "  Fetching ... $($Index) to $($Index+100)"
        $Items = @((Invoke-RestMethod -Uri $RestUrl -Headers $Token.headers -Method Get).value)

        $AllItems += $Items
        $Index += 100
            
    } until ($Items.Count -lt 100)

    Write-Host "  Fetched $($AllItems.count) items"

    $Assets = $AllItems | Select-Object `
                            @{Name='Type';Expression={$Label}},`
                            Id, Name,`
                            @{Name='Size(MB)';Expression={$_.AssetSize/1MB}}, `
                            PrivacyMode, State, VideoMigrationStatus, Published, PublishedDate, ContentType, Created, Modified, `
                            @{name='Media.Duration';Expression={$_.Media.Duration}},`
                            @{name='Media.Height';Expression={$_.Media.Height}},`
                            @{name='Media.Width';Expression={$_.Media.Width}},`
                            @{name='Metrics.Comments';Expression={$_.Metrics.Comments}},`
                            @{name='Metrics.Likes';Expression={$_.Metrics.Likes}},`
                            @{name='Metrics.Views';Expression={$_.Metrics.Views}}, `
                            @{name='ViewVideoUrl';Expression={("https://web.microsoftstream.com/video/" + $_.Id)}}
        
    write-output $Assets
}

# ----------------------------------------------------------------------------------------------
function Get-StreamToken() {
        
    $TenantInfo = Show-OAuthWindowStream -url "https://web.microsoftstream.com/?noSignUpCheck=1" -WindowTitle  "Please login to Microsoft Stream ..."
    $Token = $TenantInfo.AccessToken
    $Headers = @{
        "Authorization"   = ("Bearer " + $Token)
        "accept-encoding" = "gzip, deflate, br"
    }
    $UrlTenant = $TenantInfo.ApiGatewayUri
    $ApiVersion = $TenantInfo.ApiGatewayVersion
        
    $UrlBase = "$UrlTenant{0}?`$skip=0&`$top=100&adminmode=true&api-version=$ApiVersion" 
        
    $RequestToken = [PSCustomObject]::new()
    $RequestToken | Add-Member  -Name "token" -MemberType NoteProperty -Value  $Token
    $RequestToken | Add-Member  -Name "headers" -MemberType NoteProperty -Value  $Headers
    $RequestToken | Add-Member  -Name "tenantInfo" -MemberType NoteProperty -Value $TenantInfo
        
    $Urls = [PSCustomObject]::new()
    $RequestToken | Add-Member  -Name "urls" -MemberType NoteProperty -Value  $Urls

    $RequestToken.urls | Add-Member  -Name "Videos" -MemberType NoteProperty -Value  ($UrlBase -f "videos")
    $RequestToken.urls | Add-Member  -Name "Channels" -MemberType NoteProperty -Value   ($UrlBase -f "channels")
    $RequestToken.urls | Add-Member  -Name "Groups" -MemberType NoteProperty -Value  ($UrlBase -f "groups")
        
    $UrlBase = $UrlBase.replace("`$skip=0&", "")
    $RequestToken.urls | Add-Member  -Name "Principals" -MemberType NoteProperty -Value   ($UrlBase -f "principals")

    write-output $RequestToken
}

$StreamToken = Get-StreamToken
$ExtractData = Get-RequestedAssets -token $StreamToken -Url $StreamToken.Urls.Videos -Label "Videos"

if( $OutputCsvFileName ) {
    $ExtractData | Export-CSV $OutputCsvFileName -NoTypeInformation -Encoding UTF8
    if( $OpenFileWhenComplete ) {
        Invoke-Item $OutputCsvFileName
    }
} else {
    write-output $ExtractData
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Rodrigo Pinto |
| Twan van Beers |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/stream-report-videos" aria-hidden="true" />
