---
plugin: add-to-gallery
---

# Add demo content from a website such as Wikipedia

## Summary

This sample shows how you can generate a set of demo content from a website such as Wikipedia. This is intended to build content for testing, especially for systems such as Viva Topics. The content may not render perfectly but build out a load of documents in the environment.


## Implementation

Install Pandoc using the instructions on [their site](https://pandoc.org/installing.html).

Open Windows Powershell ISE

Navigate to the script folder

Run the command and have some patience (it takes a while for a lot of docs) - examples are in the script below

# [PnP PowerShell](#tab/pnpps)

```powershell

<#
    .SYNOPSIS
    The script used Pandoc to generate Word files from a set of html files.

    .DESCRIPTION
    Have you ever needed to have a large amount of documents but didn't just want to duplicate the same thing?
    This is especially useful for generating content to try with Viva Topics.
    The script will crawl through a website defined in the properties, extract the HTML, save that as a Word document using Pandoc and upload that to a defined SharePoint library.
    Properties allow you to define how many files to generate and how many layers to go.

    Pre-requisites:
        - Pandoc must be installed - https://pandoc.org/installing.html
    
    .EXAMPLE
    .\GenerateDocs.ps1 -TargetUrl https://contoso.sharepoint.com/sites/DemoContent-SharePoint -WebUrl "https://www.mcd79.com"

    .EXAMPLE
    .\GenerateDocs.ps1 -TargetUrl https://contoso.sharepoint.com/sites/DemoContent-SharePoint -TargetLibrary "Content" -WebUrl "https://www.mcd79.com"

    .EXAMPLE
    .\GenerateDocs.ps1 -TargetUrl https://contoso.sharepoint.com/sites/DemoContent-SharePoint -WebUrl "https://www.wikipedia.org" -WebExtension "wiki/SharePoint"

    .EXAMPLE
    .\GenerateDocs.ps1 -TargetUrl https://contoso.sharepoint.com/sites/DemoContent-SharePoint -WebUrl "https://www.wikipedia.org" -WebExtension "wiki/SharePoint" -maxLinks 5000 -maxLevels 5

    .PARAMETER WebUrl
    The base URL of the webpage to be inventoried e.g. https://www.wikipedia.org

    .PARAMETER WebExtension
    An optional parameter to define a specific page to start from e.g. wiki/SharePoint

    .PARAMETER TargetUrl
    The URL of the SharePoint Online site where the content should be loaded.

    .PARAMETER TargetLibrary
    The URL of the SharePoint Online site where the content should be loaded.

    .PARAMETER MaxLinks
    The maximum number of links to navigate through

    .PARAMETER MaxLevels
    The maximum number of levels to traverse
#>

[CmdletBinding()]
param(
    [parameter(Mandatory = $true)][string]$WebUrl,
    [parameter(Mandatory = $false)][string]$WebExtension = "",
    [parameter(Mandatory = $true)][string]$TargetUrl,
    [parameter(Mandatory = $false)][string]$TargetLibrary = "Shared Documents",
    [parameter(Mandatory = $false)][int]$maxLinks = 200,
    [parameter(Mandatory = $false)][int]$maxLevels = 5
)


$Script:maxLinks = $maxLinks
$Script:maxLevels = $maxLevels
$Script:numberLinks = 0

$Script:linksVisited = @()
Function CrawlLink($site, $level) {
    Try {
        Write-Output "Crawling $site"
        $request = Invoke-WebRequest $site
        $content = $request.Content

        $pattern = '[\\/]'
        $htmlName = $site -replace 'http://', ''
        $htmlName = $htmlName -replace 'https://', ''
        $htmlName = $htmlName -replace $pattern, '-'
        $outputFile = "./outputs/$htmlName.html"
        $outputDoc = "./outputs/$htmlName.docx"

        $content | Out-File -Path $outputFile
        $exe = "pandoc.exe"
        &$exe $outputFile -o $outputDoc -f html -t docx
        Add-PnPFile -Path $outputDoc -Folder $targetLibrary
        Remove-Item -Path $outputFile
        Remove-Item -Path $outputDoc
        #pandoc  -s -S $outputFile -o $outputDoc

        $domain = ($site.Replace("http://", "").Replace("https://", "")).Split('/')[0]
        $start = 0
        $end = 0
        $start = $content.IndexOf("<a ", $end)
        while ($start -ge 0) {
            if ($start -ge 0) {
                #Write-Output $start

                # Get the position of of the beginning of the link. The +6 is to go past the href="
                $start = $content.IndexOf("href=", $start) + 6
                if ($start -ge 6) {
                    $end = $content.IndexOf("""", $start)
                    $end2 = $content.IndexOf("'", $start)
                    if ($end2 -lt $end -and $end2 -ne -1) {
                        $end = $end2
                    }
                    if ($end -ge $start) {
                        
                        $link = $content.Substring($start, $end – $start)
                        
                        # Handle case where link is relative
                        if ($link.StartsWith("/")) {
                            $link = $site.Split('/')[0] + "//" + $domain + $link
                        }
                        if ($Script:numberLinks -le $Script:maxLinks -and $level -le $Script:maxLevels) {
                            if (($Script:linksVisited -notcontains $link) -and $link.StartsWith("https:")) {
                                $Script:numberLinks++
                                $newDomain = ($link.Replace("http://", "").Replace("https://", "")).Split('/')[0]
                                Write-Output "$newDomain - $WebUrl"

                                if ($newDomain -eq $WebUrl.Replace("http://", "").Replace("https://", "")) {
                                    #Write-Output $Script:numberLinks"["$level"] – "$link -BackgroundColor Blue -ForegroundColor White
                                    $Script:linksVisited += $link
                                    CrawlLink $link ([int]($level + 1))
                                }
                            }
                        }
                    }
                }
            }
            $start = $content.IndexOf("<a ", $end)
        }
    }
    Catch [system.exception] {
        Write-Output "ERROR: $_"
    }
}

Connect-PnPOnline $TargetUrl -Interactive
CrawlLink "$WebUrl/$extension" 0

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

## Contributors

| Author(s) |
|-----------|
| [Kevin McDonnell](https://github.com/kevmcdonk)|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-add-demo-content-from-site" aria-hidden="true" />
