# Converting SharePoint Sharing Links to Canonical URLs

## Summary

During a recent community discussion, Suhail Sayed presented an interesting challenge that many organizations face during SharePoint tenant migrations. The problem? Converting sharing links to their canonical URLs when documents are migrated between tenants.

---

## The Challenge

When migrating SharePoint documents from one tenant to another, organizations often encounter a specific issue with document references:

### The Problem Scenario:

- **Source tenant**: Documents contain reference links to other documents
- **Migration requirement**: Update these links to reflect the new tenant
- **Complication**: Links were created using the **Share** option, not the **Copy Link** option


### Why This Matters:

When you generate a link using SharePoint's Share function, it creates a unique link with a randomly generated ID that redirects to the correct canonical URL. These unique IDs have no meaning on the new tenant, making simple find-and-replace operations ineffective.

### Example URLs:

**Sharing Link Format:**

```
https://contoso.sharepoint.com/:f:/s/Company311/Et83kyw3weBCqfgt9R73ZVgBDxDRU71gOt1Qkqb99kKubQ
```

**Canonical URL Format:**

```
https://contoso.sharepoint.com/sites/Company311/Shared Documents/Test1/Folder_57/TestDoc_6.docx
```

The script is to extract sharing link information and map them to their corresponding canonical URLs.

### Prerequisites

- The user account that runs the script must have access to the SharePoint Online site.

# [PnP PowerShell](#tab/pnpps)

```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$LinkUrl
)

# Extract site name from sharing link
$siteName = $LinkUrl.Split('/')[5]
Write-Host "Extracted site name: $siteName" -ForegroundColor Green
$path = "sites"
# Build site URL from site name
$uri = [System.Uri]$LinkUrl
$tenantUrl = "$($uri.Scheme)://$($uri.Host)"
$siteUrl = "$tenantUrl/$path/$($siteName.ToLower())"
Write-Host "Built site URL: $siteUrl" -ForegroundColor Cyan

connect-PnPOnline -Url $siteUrl 

# Function to find file URL by searching sharing links
function Find-FileUrlByLinkUrl {
    param(
        [string]$SearchLinkUrl
    )
    
    Write-Host "Searching for file URL corresponding to sharing link..." -ForegroundColor Yellow
    
    # Get all lists in the site
    $lists = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false }
    
    # Flag to track if we found a match
    $found = $false
    
    foreach ($list in $lists) {
        if ($found) { break }  # Exit if already found
        
        Write-Host "Searching in library: $($list.Title)" -ForegroundColor Cyan
        
        try {
           # Search folders first
           $Folders= Get-PnPListItem -List $list -Fields "FileRef", "FileLeafRef", "FileSystemObjectType" | Where-Object { $_.FileSystemObjectType -eq "Folder" }
           
           foreach ($folder in $folders) { 
            if ($found) { break }  # Exit if already found
            
            $flinks = Get-PnPFolderSharingLink -Folder $folder['FileRef'] -ErrorAction SilentlyContinue 
                foreach ($flink in $flinks) {
                    # Check if the link URL matches our search URL
                    if ($flink.Link.WebUrl -eq $SearchLinkUrl) {         
                        Write-Host "✓ Found matching folder!" -ForegroundColor Green
                        Write-Host "  Folder Name: $($folder['FileLeafRef'])" -ForegroundColor White
                        Write-Host "  Folder URL: $($folder['FileRef'])" -ForegroundColor White
                        Write-Host "  Full URL: $tenantUrl$($folder['FileRef'])" -ForegroundColor Green
                        Write-Host "  Library: $($list.Title)" -ForegroundColor White
                        Write-Host "  Link Type: $($flink.Link.Type)" -ForegroundColor White
                        Write-Host "  Link Scope: $($flink.Link.Scope)" -ForegroundColor White
                        
                        return @{
                            FileName = $folder['FileLeafRef']
                            FileUrl = $folder['FileRef']
                            FullUrl = "$tenantUrl$($folder['FileRef'])"
                            Library = $list.Title
                            LinkType = $flink.Link.Type
                            LinkScope = $flink.Link.Scope
                            SharingLink = $flink.Link.WebUrl
                        }
                    }
                }
            }

           # Search files only if not found in folders
           if (-not $found) {
               $items  = get-pnplistitem -List $list -Fields "FileRef", "FileLeafRef", "FileSystemObjectType" -PageSize 5000 | Where-Object { $_.FileSystemObjectType -eq "File" }          
                foreach ($item in $items) {
                    if ($found) { break }  # Exit if already found
                    
                    # Get sharing links for each item
                    $sharingLinks = Get-PnPFileSharingLink -Identity $item['FileRef']
                    
                    foreach ($link in $sharingLinks) {
                        # Check if the link URL matches our search URL
                        if ($link.Link.WebUrl -eq $SearchLinkUrl) {
                            
                            Write-Host "✓ Found matching file!" -ForegroundColor Green
                            Write-Host "  File Name: $($item['FileLeafRef'])" -ForegroundColor White
                            Write-Host "  File URL: $($item['FileRef'])" -ForegroundColor White
                            Write-Host "  Full URL: $tenantUrl$($item['FileRef'])" -ForegroundColor Green
                            Write-Host "  Library: $($list.Title)" -ForegroundColor White
                            Write-Host "  Link Type: $($link.Link.Type)" -ForegroundColor White
                            Write-Host "  Link Scope: $($link.Link.Scope)" -ForegroundColor White
                            
                            return @{
                                FileName = $item['FileLeafRef']
                                FileUrl = $item['FileRef']
                                FullUrl = "$tenantUrl$($item['FileRef'])"
                                Library = $list.Title
                                LinkType = $link.Link.Type
                                LinkScope = $link.Link.Scope
                                SharingLink = $link.Link.WebUrl
                            }
                        }
                    }
                }
            }
        }
        catch {
            Write-Host "  Error searching in $($list.Title): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "No matching file found for the provided sharing link." -ForegroundColor Yellow
    return $null
}

# Search for the file corresponding to the sharing link
$fileInfo = Find-FileUrlByLinkUrl -SearchLinkUrl $LinkUrl

if ($fileInfo) {
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "FILE FOUND!" -ForegroundColor Green
    Write-Host "File: $($fileInfo.FileName)" -ForegroundColor White
    Write-Host "URL: $($fileInfo.FullUrl)" -ForegroundColor White
    Write-Host "========================================`n" -ForegroundColor Green
}
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Source Credit

Sample first appeared on [Converting SharePoint Sharing Links to Canonical URLs with PowerShell](https://reshmeeauckloo.com/posts/powershell-sharepoint-getfileurl-basedon-sharingurl/)

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011) |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-get-canonical-url-from-sharinglink" aria-hidden="true" />
