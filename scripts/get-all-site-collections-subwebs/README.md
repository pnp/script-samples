---
plugin: add-to-gallery
---

# How to to get all site collections with their sub webs

## Summary

Sometimes we have a business requirement to get site collections with all the sub-webs so we can achieve the solution easily using PnP Powershell.

![Example Screenshot](assets/example.png)

result with CLI version of the script

![Example Cli Screenshot](assets/example_cli.png)

Let's see step-by-step implementation

## Implementation

Open Windows Powershell ISE
Create a new file and write a script

Now we will see all the steps which we required to achieve the solution:

1. We will initialize the admin site URL, username, and password in the global variables.
2. Then we will create a Login function to connect the O365 SharePoint Admin site.
3. Create a function to get all site collections and all the sub-webs

So in the end, our script will be like this

# [PnP PowerShell](#tab/pnpps)

```powershell

$SiteURL = "https://domain-admin.sharepoint.com/"
$UserName = "UserName@domain.onmicrosoft.com"
$Password = "********"
$SecureStringPwd = $Password | ConvertTo-SecureString -AsPlainText -Force 
$Creds = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $SecureStringPwd

Function Login {
    [cmdletbinding()]
    param([parameter(Mandatory = $true, ValueFromPipeline = $true)] $Creds)
    Write-Host "Connecting to Tenant Admin Site '$($SiteURL)'" 
    Connect-PnPOnline -Url $SiteURL -Credentials $creds
    Write-Host "Connection Successfull"
}

Function AllSiteCollAndSubWebs() {
    Login($Creds)
    $TenantSites = (Get-PnPTenantSite) | Select Title, Url       
       
    ForEach ( $TenantSite in $TenantSites) { 
        Connect-PnPOnline -Url $TenantSite.Url -Credentials $Creds
        Write-Host $TenantSite.Title $TenantSite.Url
        $subwebs = Get-PnPSubWebs -Recurse | Select Title, Url
        foreach ($subweb in $subwebs) { 
            Connect-PNPonline -Url $subweb.Url -Credentials $Creds
            Write-Host $subweb.Title $subweb.Url 
        }  
    }
}

AllSiteCollAndSubWebs

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell

function PrintSite([string]$type, $sitesJson) {
    $sites = $sitesJson | ConvertFrom-Json
    $sitesCount = $sites.Count
    Write-Host "--------------------------------------------------------------------"
    Write-Host "$type (amount: $sitesCount):"
    foreach ($site in $sites) {
        Write-Host $site.Title $site.Url    
        $subWebs = m365 spo web list -u $site.Url
        $subWebs = $subWebs | ConvertFrom-Json
        foreach ($subWeb in $subWebs) {
            Write-Host $subWeb.Title $subWeb.Url
        }
    }
}

function AllSiteCollAndSubWebs() {
    $m365Status = m365 status
    if ($m365Status -match "Logged Out") {
        m365 login
    }

    $teamSites = m365 spo site list --type TeamSite
    PrintSite -type 'Team Sites' -sitesJson $teamSites

    $communicationSites = m365 spo site list --type CommunicationSite
    PrintSite -type 'Communication Sites' -sitesJson $communicationSites

    $classicSites = m365 spo site classic list
    PrintSite -type 'Classic Sites' -sitesJson $classicSites

    $deletedSites = m365 spo site list --deleted
    PrintSite -type 'Deleted Sites' -sitesJson $deletedSites
}

AllSiteCollAndSubWebs

```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [How to to get all site collections with their sub webs using PnP PowerShell? | Microsoft 365 PnP Blog](https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/how-to-to-get-all-site-collections-with-their-sub-webs-using-pnp/ba-p/2322131)

## Contributors

| Author(s) |
|-----------|
| Chandani Prajapati |
| Adam Wójcik |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/get-all-site-collections-subwebs" aria-hidden="true" />
