---
plugin: add-to-gallery
---

# Export and import library folder structure

## Summary

Sometimes you just need to copy a folder structure from one library to another. This script will export the folder structure from one library and import it to another library using a JSON file to store the folder structure. The can be used as is or be an invidual function in a site provisioning script.


![Example Screenshot](assets/example.png)


# [PnP PowerShell](#tab/pnpps)

```powershell
# export part 

function Get-Folderstructure 
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$folderUrl,
        [Parameter(Mandatory=$true)]
        [string]$folderName,
        [Parameter(Mandatory=$true)]
        [string]$ListName,
        [Parameter(Mandatory=$true)]
        [int]$level
        
    )
   # $thisFolder = Get-PnPFolder -Url $folderUrl -Connection $conn
   if($folderName -eq "Forms")
   {
        continue 
   }
    $result = $null
    $folderColl=Get-PnPFolderItem -FolderSiteRelativeUrl $folderUrl -ItemType Folder -Connection $conn  
    $leaves = @()
    $elements = @()
    foreach($folder in $folderColl)
    {
        
        $subFolderURL= $folderUrl+"/"+$folder.Name
        $testForSubFolders=Get-PnPFolderItem -FolderSiteRelativeUrl $subFolderURL -ItemType Folder -Connection $conn  
        if($testForSubFolders.Count -gt 0)
        {
            write-host "subfolder found for folder $($folder.Name) at level $level" -ForegroundColor Yellow
            $level = $level+1
            $result = Get-Folderstructure -folderUrl $subFolderURL -ListName $ListName -folderName $folder.Name -level $level            
            $result = $result | ConvertFrom-Json -Depth 100
            $elements += $result

        }
        else 
        {
            #Write-Host "leaf node $($folder.Name)" -ForegroundColor Yellow
            $FolderItem = Get-PnPListItem -List $ListName -UniqueId $folder.UniqueId -ErrorAction Stop -Connection $conn
            $foldercolor = $FolderItem.FieldValues["_ColorHex"]
            if($foldercolor)
            {
                Write-Host "color found for folder $($folder.Name) - $foldercolor" -ForegroundColor Green
            }
            $leave = [PSCustomObject]@{Name = $folder.Name; Color = $foldercolor}    
            $elements += $leave
        }
        
        
    }
    if($elements.Count -gt 0)
    {

        $folder = Get-PnPFolder -Url $folderUrl -Connection $conn
        $UniqueId = Get-PnPProperty -ClientObject $folder -Property UniqueId -Connection $conn
        
        $FolderItem = Get-PnPListItem -List $ListName -UniqueId $UniqueId -ErrorAction Stop -Connection $conn
        $foldercolor = $FolderItem.FieldValues["_ColorHex"]
        if($foldercolor)
        {
            Write-Host "color found for folder $($folder.Name) - $foldercolor" -ForegroundColor Green
        }
        $element = [PSCustomObject]@{
            Name = $folderName
            Color = $foldercolor
            Folders = $elements
        }
    }
    
    $element = $element | ConvertTo-Json -Depth 100
    return $element
}
$url = "https://contoso.sharepoint.com/sites/thesite"
$conn = Connect-PnPOnline -Url $url -Interactive -ReturnConnection

$finalJson = @()
$finalJson = Get-Folderstructure -folderUrl "/Shared Documents"
$finalJson | ConvertTo-Json -Depth 100
#write result to file
$finalJson | Out-File -FilePath "C:\temp\folderstructureRecursive.json" -Force

################################
# import part

function SetFolder 
{
    #add mandatory parameter folder
    param(
        [Parameter(Mandatory=$true)]
        [object]$folder,
        [Parameter(Mandatory=$true)]
        [string]$folderurl,
        [Parameter(Mandatory=$true)]
        [string]$documentLibrary
    )
    $createdFolder = Add-PnPFolder -Name $folder.Name -Folder $folderurl -ErrorAction Stop -Connection $conn    
    # Get the created folder item
    $newFolderItem = Get-PnPListItem -List $documentLibrary -UniqueId $createdFolder.UniqueId -ErrorAction Stop -Connection $conn
    $folderColor = $folder.Color
    # Change the value of the _ColorHex column of the created folder to change the color
    Set-PnPListItem -List $documentLibrary -Identity $newFolderItem.Id -Values @{"_ColorHex" = $folderColor } -ErrorAction Stop  -Connection $conn  

    foreach($folder in $folder.Folders)
    {
        SetFolder -folder $folder -folderurl $createdFolder.ServerRelativeUrl -documentLibrary $documentLibrary
    }
}
    


function Set-FolderstructurefromJson 
{
    param(
        [Parameter(Mandatory=$true)]
        [object]$json,
        [Parameter(Mandatory=$true)]
        [string]$folderName,
        [Parameter(Mandatory=$true)]
        [string]$documentLibrary
    )
    $folders = $json.Folders

    foreach($folder in $folders)
    {
        $res = SetFolder -folder $folder -folderurl $folderName -documentLibrary $documentLibrary 
    }

}

$url = "https://contoso.sharepoint.com/sites/targetsite/"
$conn = connect-pnponline -URL $url -Interactive -ReturnConnection

#the json file can be stored in a document library or locally
$jsonUrl = "/sites/SampleTeamSite/Shared%20Documents/folderstructureRecursive.json"
$jsonSiteUrl = "https://contoso.sharepoint.com/sites/SampleTeamSite"
$jsonsiteconn = Connect-PnPOnline -Url $jsonSiteUrl  -Interactive -ReturnConnection

$file = Get-PnPFile -Url $jsonUrl -AsString -Connection $jsonsiteconn
$json = ConvertFrom-Json $file 

#if you want start the folder structure in the root of the library
Set-FolderstructurefromJson -json $json -folderName "Shared Documents/"

#if you want to start the folder structure in a subfolder of the library
Set-FolderstructurefromJson -json $json -folderName "Shared Documents/General"

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


## Contributors

| Author(s) |
|-----------|
| Kasper Larsen |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-export-import-folderstructure" aria-hidden="true" />
