---
plugin: add-to-gallery
---

# Add multiple folders in libraries using a csv file

## Summary

Below is an example of the format needed for your .csv file:

| libName | folderName |
| --------| ---------- |
| Customers | Contracts |
| Support | Roadmaps |
| Support | Analysis |
 
> [!important]
> Make sure your target libraries contained in the file do exist in SharePoint Online.


# [PnP PowerShell](#tab/pnpps)
```powershell

#Config Variables
$SiteURL = "https://contoso.sharepoint.com/sites/Ops"
$CSVFilePath = "C:\Temp\Folders.csv"
 
Try {
    #Connect to PnP Online
    Connect-PnPOnline -Url $SiteURL -Interactive
    $Web = Get-PnPWeb
 
    #Get the CSV file
    $CSVFile = Import-Csv $CSVFilePath
  
    #Read CSV file and create folders
    ForEach($Row in $CSVFile)
    {
        #Get the Document Library and its site relative URL
        $Library = Get-PnPList -Identity $Row.libName -Includes RootFolder
        If($Web.ServerRelativeUrl -eq "/")
        {
            $LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl
        }
        else
        {
            $LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl.Replace($Web.ServerRelativeUrl,'')
        }
        #Replace Invalid Characters from Folder Name, If any
        $FolderName = $Row.folderName
        $FolderName = [RegEx]::Replace($FolderName, "[{0}]" -f ([RegEx]::Escape([String]'\"*:<>?/\|')), '_')
 
        #Frame the Folder Name
        $FolderURL = $LibrarySiteRelativeURL+"/"+$FolderName
 
        #Create Folder if it doesn't exist
        Resolve-PnPFolder -SiteRelativePath $FolderURL | Out-Null
        Write-host "Ensured Folder:"$FolderName -f Green
    }
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***


Below is an example of the format needed for your .csv file:

| libName | folderName | site |
| --------| ---------- | ---- |
| Customers | Contracts | https://contoso.sharepoint.com/sites/site1 |
| Support | Roadmaps |  https://contoso.sharepoint.com/sites/site2 |
| Support | Analysis | https://contoso.sharepoint.com/sites/site2 |

> [!important]
> Make sure your target libraries & sites contained in the file do exist in SharePoint Online.
 

 # [PnP PowerShell](#tab/pnpps2)
```powershell

#Config Variables
$CSVFilePath = "C:\Temp\Folders.csv"
 
Try {
    
 
    #Get the CSV file
    $CSVFile = Import-Csv $CSVFilePath
  
    #Read CSV file and create folders
    ForEach($Row in $CSVFile)
    {
        $SiteURL = $Row.site
        #Connect to PnP Online
        Connect-PnPOnline -Url $SiteURL -Interactive
        $Web = Get-PnPWeb
        #Get the Document Library and its site relative URL
        $Library = Get-PnPList -Identity $Row.libName -Includes RootFolder
        If($Web.ServerRelativeUrl -eq "/")
        {
            $LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl
        }
        else
        {
            $LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl.Replace($Web.ServerRelativeUrl,'')
        }
        #Replace Invalid Characters from Folder Name, If any
        $FolderName = $Row.folderName
        $FolderName = [RegEx]::Replace($FolderName, "[{0}]" -f ([RegEx]::Escape([String]'\"*:<>?/\|')), '_')
 
        #Frame the Folder Name
        $FolderURL = $LibrarySiteRelativeURL+"/"+$FolderName
 
        #Create Folder if it doesn't exist
        Resolve-PnPFolder -SiteRelativePath $FolderURL | Out-Null
        Write-host "Ensured Folder:"$FolderName -f Green
    }
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| [Jiten Parmar](https://github.com/jitenparmar) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-add-multiple-folders-in-libraries-using-csv-file" aria-hidden="true" />
