

# Integrate MailChimp Campaigns API with SPO to create wiki pages based on email sent from MailChimp


## Summary

This PowerShell script automates the integration of MailChimp and SharePoint by connecting to SharePoint using PnP PowerShell, retrieving MailChimp campaigns based on specified date ranges, extracting and cleaning HTML content from these campaigns, downloading and uploading images to SharePoint, creating and publishing a SharePoint Wiki page with the cleaned HTML content, and updating bulletin links on a designated SharePoint page. The script handles various tasks, including removing unwanted scripts and styles from the HTML, moving published pages to a specified folder, and ensuring that all image URLs in the HTML content are updated to point to the images stored in SharePoint. 

# [PnP PowerShell](#tab/pnpps)

```powershell

$mailChimpApiKey = ""
$siteUrl = "https://<your-sharepoint-site-url>"
$relativeUrl = "/sites/<your-site-name>"
$wikiFolder = "$relativeUrl/SitePages/WikiFolder/"
$wikiPageUrl = "$relativeUrl/SitePages/"
$apiEndpoint = "https://<DC>.api.mailchimp.com/3.0/campaigns"
#On line 85, replace the search string for your campaign - NOTE LINE NUMBERS MAY CHANGE
#On line 101, provide the local path to where the images should be stored for later upload to SPO
#On line 107 and 110, replace WikiDocLib with the existing document library on SPO to store images
function Connect-ToSharePoint {
    param (
        [string]$siteUrl
    )
    #The sample uses a certificate to connect. You can also use -WebLogin but -Interactive is no longer supported
    $connectToSP = Connect-PnPOnline -Url $siteUrl -ClientId "<your-client-id>" -Thumbprint "<your-thumbprint>" -Tenant "<your-tenant-id>" -ReturnConnection
    return $connectToSP
}

function Get-MailChimpCampaigns {
    param (
        [string]$mailChimpApiKey,
        [string]$sinceSendTime,
        [string]$beforeSendTime
    )
    $headers = @{
        "Authorization" = "Bearer $mailChimpApiKey"
    }
    $apiEndpoint = "$apiEndpoint?since_send_time=$sinceSendTime&before_send_time=$beforeSendTime&sort_field=send_time&sort_dir=DESC&status=sent"
    $response = Invoke-RestMethod -Uri $apiEndpoint -Headers $headers -Method Get
    return $response
}

function Extract-HTMLContent {
    param (
        [string]$mailChimpUrl,
        [object]$headers
    )
    $response = Invoke-RestMethod -Uri $mailChimpUrl -Headers $headers -Method Get
    return $response.html
}

function Clean-HTMLContent {
    param (
        [string]$htmlContent
    )
    $pattern = '<body[^>]*>([\s\S]*?)<\/body>'
    if ($htmlContent -match $pattern) {
        $bodyContent = $matches[1]
        $bodyContent = $bodyContent -replace '<script[^>]*>[\s\S]*?<\/script>', ''
        $bodyContent = $bodyContent -replace '<style[^>]*>[\s\S]*?<\/style>', ''
        $bodyContent = $bodyContent -replace '<!--[\s\S]*?-->', ''
    } else {
        $bodyContent = "No body content found"
    }
    return $bodyContent
}

function Create-PublishWikiPage {
    param (
        [object]$connectToSP,
        [string]$pageTitle,
        [string]$bodyContent
    )
    $pageName = $pageTitle
    Add-PnPWikiPage -ServerRelativePageUrl "$wikiPageUrl$pageName" -Content $bodyContent -Connection $connectToSP
    Move-PnPFile -SourceUrl "SitePages/$pageName" -TargetUrl "$wikiFolder$pageName" -Overwrite -Force -Connection $connectToSP

    $mContext = Get-PnPContext -Connection $connectToSP
    $newPageAsListItem = Get-PnPFile -Url "$wikiFolder$pageName" -AsListItem -Connection $connectToSP
    $newPageAsFile = $newPageAsListItem.File
    $mContext.Load($newPageAsFile)
    $mContext.ExecuteQuery()
    $newPageAsFile.Publish("Published via PowerShell script to automate")
    $mContext.ExecuteQuery()
}


$connectToSP = Connect-ToSharePoint -siteUrl $siteUrl
$currentYear = (Get-Date).Year
$currentMonth = (Get-Date).Month
$sinceSendTime = (Get-Date -Year $currentYear -Month $currentMonth -Day 1).ToString("yyyy-MM-ddTHH:mm:ssZ")
$beforeSendTime = (Get-Date).ToString("yyyy-MM-ddT23:59:59Z")
$jsonCampaignResponse = Get-MailChimpCampaigns -mailChimpApiKey $mailChimpApiKey -sinceSendTime $sinceSendTime -beforeSendTime $beforeSendTime

if ($jsonCampaignResponse.campaigns[0].settings.subject_line.Contains("<REPLACE WITH STRING TO FIND ON MC>")) {
    Write-Host $jsonCampaignResponse.campaigns[0].settings.subject_line
    $campaignId = $jsonCampaignResponse.campaigns[0].Id
}

$pageTitle = "{0}.{1}" -f $jsonCampaignResponse.campaigns[0].settings.subject_line, "aspx"
$mailChimpUrl = "$apiEndpoint/$campaignId/content"
$htmlContent = Extract-HTMLContent -mailChimpUrl $mailChimpUrl -headers $headers
$bodyContent = Clean-HTMLContent -htmlContent $htmlContent

$imageSrcMatches = [regex]::Matches($bodyContent, '<img[^>]+src="([^">]+)"')
$imageSrcs = foreach ($match in $imageSrcMatches) { $match.Groups[1].Value }

$imagePaths = @()
foreach ($src in $imageSrcs) {
    $fileName = [System.IO.Path]::GetFileName($src)
    $filePath = "C:\users\<your-user-name>\downloads\TESTIMG\$filename"
    Invoke-WebRequest -Uri $src -OutFile $filePath
    $imagePaths += $filePath
}

$newFolderName = $jsonCampaignResponse.campaigns[0].settings.subject_line
Add-PnpFolder -Name $newFolderName -Folder "WikiDocLib" -ErrorAction Continue -Connection $connectToSP
$newImageUrls = @()
foreach ($imagePath in $imagePaths) {
    $uploadedFile = Add-PnPFile -Path $imagePath -Folder "WikiDocLib/$newFolderName" -Connection $connectToSP
    $newImageUrls += $uploadedFile.ServerRelativeUrl
}

$updatedHtml = $bodyContent
for ($i = 0; $i -lt $imageSrcs.Count; $i++) {
    $oldSrc = [regex]::Escape($imageSrcs[$i])
    $newSrc = $newImageUrls[$i]
    $updatedHtml = [regex]::Replace($updatedHtml, "(<img[^>]*src=[""'])$oldSrc([""'][^>]*>)", "`$1$newSrc`$2")
}

$bodyContent = $updatedHtml

Create-PublishWikiPage -connectToSP $connectToSP -pageTitle $pageTitle -bodyContent $bodyContent

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| R. Ali |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-mailchimp-integration" aria-hidden="true" />
