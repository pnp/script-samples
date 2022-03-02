---
plugin: add-to-gallery
---

# Sample on exporting Document libraries inc folders and versions for selected Site Collections to a Fileshare/drive

## Summary
The purpose of this script is to Export Document libraries inc folders and versions for selected Site Collections to a Fileshare/drive. This could be useful if you need a complate version history for each document in a site collection, but don't like paying for SharePoint storage for each version. Copy the files to a cheaper storage option and delete any redundent version.


## Implementation

- Open VS Code or similar editor , ensure you are using POwerShell 7.2 or above
- Create a new file
- Write a script as below,
- Change the variables to target to your environment, site, document library, document path, max count
- Run the script.
 
## Screenshot of Output 

![Example Screenshot](assets/preview.png)

# [PnP.PowerShell](#tab/pnpps)
```powershell


#The purpose of this script is to export Document libraries inc folders and versions for selected Site Collections to a Fileshare/drive

#Set Variables
$SharePointAdminSiteURL = "https://[Your tenant]-admin.sharepoint.com"
$SharePointRootURL = "https://[Your tenant].sharepoint.com/sites/"
$DownloadPath ="C:\Exporting\"

#Get Credentials to connect
if(-not $Cred)
{
    $Cred = Get-Credential
}


function HandleList ($ListName, $SiteCollectionTitle,  $WebTitle, $connection)
{
    try
    {
        $List = Get-PnPList -Identity $ListName -Connection $connection
    
        #Get all Items from the Library - with progress bar
        # Thanks to https://www.sharepointdiary.com/2017/03/sharepoint-online-download-all-files-from-document-library-using-powershell.html  for that basic
        $global:counter = 0
        if($List.ItemCount -gt 0 )
        {
            $ListItems = Get-PnPListItem -Connection $connection -List $ListName -PageSize 500 -Fields ID -ScriptBlock { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete `
                ($global:Counter / ($List.ItemCount) * 100) -Activity "Getting Items from List:" -Status "Processing Items $global:Counter to $($List.ItemCount)";}
                Write-Progress -Activity "Completed Retrieving Folders from List $ListName" -Completed
                
                #Get all Subfolders of the library
                $SubFolders = $ListItems | Where {$_.FileSystemObjectType -eq "Folder" -and $_.FieldValues.FileLeafRef -ne "Forms"}
                $SubFolders | ForEach-Object {
                    #Ensure All Folders in the Local Path
                    $LocalFolder = $DownloadPath + $SiteCollectionTitle + "\"+ $WebTitle + "\" + ($_.FieldValues.FileRef.Substring($Web.ServerRelativeUrl.Length)) -replace "/","\"
                    #Create Local Folder, if it doesn't exist
                    If (!(Test-Path -Path $LocalFolder)) {
                            New-Item -ItemType Directory -Path $LocalFolder | Out-Null
                    }
                    Write-host -f Yellow "Ensured Folder '$LocalFolder'"
                }
                
                #Get all Files from the folder
                $FilesColl =  $ListItems | Where {$_.FileSystemObjectType -eq "File"}
                $Ctx = Get-PnPContext 
                #Iterate through each file and download
                $FilesColl | ForEach-Object{
                    $FileDownloadPath = ($DownloadPath + $SiteCollectionTitle + "\"+ $WebTitle + "\" + ($_.FieldValues.FileRef.Substring($Web.ServerRelativeUrl.Length)) -replace "/","\").Replace($_.FieldValues.FileLeafRef,'')
                    If (!(Test-Path -Path $FileDownloadPath)) {
                        New-Item -ItemType Directory -Path $FileDownloadPath | Out-Null
                    }
                    $file = Get-PnPFile -Url $_["FileRef"] -AsFileObject -Connection $connection -ErrorAction Stop
                    $versions = Get-PnPProperty -ClientObject $file -Property Versions  -Connection $connection
                    Foreach ($fileVersion in $versions)
                    {
                        $filename = $file.Name.Substring(0, $file.Name.LastIndexOf("."))
                        $fileextention = $file.Name.Substring($file.Name.LastIndexOf(".")+1)
                        $VersionFileName = "$($FileDownloadPath)\$($filename)_$($fileVersion.VersionLabel).$fileextention"
                        #Get Contents of the File Version
                        $VersionStream = $fileVersion.OpenBinaryStream()
                        $Ctx.ExecuteQuery()
                
                        #Download File version to local disk
                        [System.IO.FileStream] $FileStream = [System.IO.File]::Open($VersionFileName,[System.IO.FileMode]::OpenOrCreate)
                        $VersionStream.Value.CopyTo($FileStream)
                        $FileStream.Close()
                        
                        Write-Host -f Green "Version $($fileversion.VersionLabel) Downloaded to :" $VersionFileName
                    }
                    #get the current version
                    Get-PnPFile -ServerRelativeUrl $_.FieldValues.FileRef -Path $FileDownloadPath -FileName $_.FieldValues.FileLeafRef -AsFile -force

                    Write-host -f Green "Downloaded File from '$($_.FieldValues.FileRef)'"
                }
            }
            
        }
        catch
        {
            throw $_.Exception
        }
        
}


function HandleWeb ($site, $web, $root, $connection)
{
    try
    {
        $DocumentLibraries = Get-PnPList -Connection $connection -ErrorAction Stop| Where-Object {$_.BaseTemplate -eq 101 -and $_.Hidden -eq $false} 
        foreach($lib in  $DocumentLibraries)
        {
            if( $lib.Title -eq "Form Templates" -or $lib.Title -eq "Style Library" -or $lib.Title -eq "Site Assets")
            {
                write-host -ForegroundColor Red "skipping $($lib.Title) "    
                continue
            }
            write-host -ForegroundColor Green "$($lib.Title) loading items"
            $webShortName = $web.ServerRelativeUrl.Substring($web.ServerRelativeUrl.LastIndexOf("/")+1)
            HandleList -ListName $lib.Title -SiteCollectionTitle $site -WebTitle $webShortName -connection $connection
        }
    }
    catch
    {
        write-host -f Red "`tError:" $_.Exception.Message
        throw $_.Exception
    }
}

function Get-SiteCollections
{
    # this function is just a way to get the site collections that are in scope for the check
  
    $conn = Connect-PnPOnline -Url $SharePointAdminSiteURL -Credentials $Cred -ReturnConnection
    #$SiteCollections = Get-PnPTenantSite -Connection $conn  
    $SiteCollections = Get-PnPTenantSite -Connection $conn  | Where-Object {$_.Template -eq "SITEPAGEPUBLISHING#0"}
    Disconnect-PnPOnline -Connection $conn
    return $SiteCollections

}
 
Try {
    
    #Get the relevant Site collections 
    $SiteCollections = Get-SiteCollections
   
    $index = 0
    #Loop through each site collection
    $totalnumber = $SiteCollections.Count
    ForEach($Site in $SiteCollections) 
    { 
        $SiteURL = $Site.Url
        Write-host -ForegroundColor Green "$($SiteURL ) , number $index of $totalnumber"
        $index++
        Try 
        {
            #Connect to site collection
            $connection = Connect-PnPOnline -Url $SiteURL -Credentials $Cred -ReturnConnection

            $siteCollectionShortUrl = $SiteURL.Substring($SiteURL.LastIndexOf("/"))
            if($siteCollectionShortUrl.Length -gt 1)
            {
                HandleWeb -site $siteCollectionShortUrl -Web (Get-PnpWeb -Connection $connection) -root $true -connection $connection
                $SubSites = Get-PnPSubWeb -Recurse -Connection $connection
                Disconnect-PnPOnline -Connection $connection
                ForEach ($web in $SubSites)
                {
                    $connection = Connect-PnPOnline -Url $web.Url -Credentials $Cred -ReturnConnection
                    Write-host "Web  : $($Web.URL)"
                    HandleWeb -site $siteCollectionShortUrl -web $web -root $false -connection $connection
                    Disconnect-PnPOnline -Connection $connection
                }
            }
            else {
                Write-Host "Site Collection URL not valid: $SiteUrl" -ForegroundColor Red
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






```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Kasper Larsen, Fellowmind|

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-export-files-and-versions" aria-hidden="true" />
