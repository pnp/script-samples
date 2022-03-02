---
plugin: add-to-gallery
---

# Reports to Excel where the specified Term is used 

## Summary

Arguments:
$RootSiteURL = "https://devenvironmentAAA.sharepoint.com/"
$targetTermSetId = "cca0fb68-25e6-4b83-a998-9ad4e82c68f8"
$targetTermId = "6816b2d7-ea71-4906-8f25-e45acc32ede2"
$outputPath = "C:\temp\whereisthatTermidused.csv" 


This sample looks through all site collections including subsites looking for lists containing managed metadata fields. If that managed metadata field "points" to the Termset specified the script checks if the value of that field matches the Term 


![Example Screenshot](assets/ReportTermUse.png)

> [!Note]
> For this sample, you will require PnP.Powershell to be installed

# [PnP PowerShell](#tab/pnpps)

```powershell

#Set Variables
$rootSiteURL = "https://devenvironment.sharepoint.com//"
$targetTermSetId = "cca0fb68-25e6-4b83-a998-9ad4e82c68f8"
$targetTermId = "6816b2d7-ea71-4906-8f25-e45acc32ede2"
$outputPath = "C:\temp\whereisthatTermidused.csv" 
#Get Credentials to connect
if(-not $Cred)
{
    $Cred = Get-Credential
}

function LookForTermInWeb ($web)
{
    #check root first
    $lists = Get-PnPList -Web $web -Connection $connection
    foreach($list in $lists)
    {
        $taxfields = Get-PnPField -List $list -Connection $connection | Where-Object {$_.TypeAsString -eq "TaxonomyFieldType"}
        foreach($taxfield in $taxfields)
        {
            if($taxfield.TermSetId -eq $targetTermSetId)
            {
                
                $listitems = Get-PnPListItem -List $list -Connection $connection
                foreach($listitem in $listitems)
                {
                    #get the termid value
                    $field = $listitem[$taxfield.InternalName]
                    if($field)
                    {
                        $termguid = $field.TermGuid
                        if($termguid -and $termguid -eq $targetTermId)
                        {
                            
                            $element = "" | Select-Object SiteUrl, Title, ListTitle, fieldname, fieldvalue
                            $element.SiteUrl = $Site.Url
                            $element.Title = $Site.Title
                            $element.ListTitle = $list.Title
                            $element.fieldname = $taxfield.Title
                            $element.fieldvalue = $field.Label
                            $outputArray.Add($element) | Out-Null
                        }
                    }
                    
                }
            }
        }
    }
}



$outputArray = [System.Collections.ArrayList]@()
 
Try {
    #Connect to PnP Online
    $connection = Connect-PnPOnline -Url $rootSiteURL -Credentials $Cred -ReturnConnection
 
    #Get All Site collections 
    $SitesCollections = Get-PnPTenantSite -Connection $connection

    Disconnect-PnPOnline -Connection $connection
    $index = 0
    #Loop through each site collection
    ForEach($Site in $SitesCollections) 
    { 
        
        Write-host -ForegroundColor Green "$($Site.Url ) , number $index of $($SitesCollections.Count)"
        $index++
        Try 
        {
            #Connect to site collection
            $connection = Connect-PnPOnline -Url $Site.Url -Credentials $Cred -ReturnConnection
            LookForTermInWeb -Web (Get-PnpWeb -Connection $connection)
            
            
            $SubSites = Get-PnPSubWeb -Recurse -Connection $connection
            ForEach ($web in $SubSites)
            {
                Write-host "Web  : $($Web.URL)"
                LookForTermInWeb -web $web
            }
        }
        Catch {
            write-host -f Red "`tError:" $_.Exception.Message
        }
        finally
        {
            if($connection)
            {
                Disconnect-PnPOnline -Connection $connection
            }
        }
    }
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}

$outputArray  | Export-Csv -Path $outputPath -Force -Encoding utf8BOM -Delimiter "|"

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Kasper Bo Larsen](https://github.com/kasperbolarsen|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/report-private-teams-excel" aria-hidden="true" />

