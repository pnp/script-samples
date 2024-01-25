---
plugin: add-to-gallery
---

# Add multiple folders in libraries using a CSV file

## Summary

### Create folders on single SharePoint site

Below is an example of the format needed for your `.csv` file:

| libName | folderName |
| --------| ---------- |
| Customers | Contracts |
| Support | Roadmaps |
| Support | Analysis |
 
> [!important]
> Make sure your target libraries contained in the file do exist in SharePoint Online site.

# [PnP PowerShell](#tab/pnpps)

```powershell
# Config Variables
$SiteURL = "https://contoso.sharepoint.com/sites/Ops"
$CSVFilePath = "C:\Temp\Folders.csv"
 
Try {
    # Connect to PnP Online
    Connect-PnPOnline -Url $SiteURL -Interactive
    $Web = Get-PnPWeb
 
    # Get the CSV file
    $CSVFile = Import-Csv $CSVFilePath
  
    # Read CSV file and create folders
    ForEach($Row in $CSVFile)
    {
        # Get the Document Library and its site relative URL
        $Library = Get-PnPList -Identity $Row.libName -Includes RootFolder

        If($Web.ServerRelativeUrl -eq "/")
        {
            $LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl
        }
        else
        {
            $LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl.Replace($Web.ServerRelativeUrl,'')
        }

        # Replace Invalid Characters from Folder Name, If any
        $FolderName = $Row.folderName
        $FolderName = [RegEx]::Replace($FolderName, "[{0}]" -f ([RegEx]::Escape([String]'\"*:<>?/\|')), '_')
 
        # Frame the Folder Name
        $FolderURL = $LibrarySiteRelativeURL+"/"+$FolderName
 
        # Create Folder if it doesn't exist
        Resolve-PnPFolder -SiteRelativePath $FolderURL | Out-Null
        Write-host "Ensured Folder:"$FolderName -f Green
    }
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
# SharePoint online site URL
$SiteURL = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/Company311)"

# Location of the CSV file
$CSVFilePath= "D:\dtemp\Folders.csv"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

Try {
    # Get the CSV file
    $CSVFile = Import-Csv $CSVFilePath
  
    # Read CSV file and create folders
    ForEach($Row in $CSVFile)
    {
        # Get the Document Library and its site relative URL
		$Library = m365 spo list get --webUrl $SiteURL --title $Row.libName --properties "Title,Id,RootFolder/ServerRelativeUrl" | ConvertFrom-Json
		$LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl

        # Replace Invalid Characters from Folder Name, If any
        $FolderName = $Row.folderName
        $FolderName = [RegEx]::Replace($FolderName, "[{0}]" -f ([RegEx]::Escape([String]'\"*:<>?/\|')), '_')
 
        # Create Folder if it doesn't exist
		m365 spo folder add --webUrl $SiteURL --parentFolderUrl $LibrarySiteRelativeURL --name $FolderName
        Write-host "Folder Created: "$FolderName -f Green
    }
}
catch {
    write-host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

### Create folders on multiple SharePoint sites

Below is an example of the format needed for your `.csv` file:

| libName | folderName | SiteUrl |
| --------| ---------- | ---- |
| Customers | Contracts | https://contoso.sharepoint.com/sites/site1 |
| Support | Roadmaps | https://contoso.sharepoint.com/sites/site2 |
| Support | Analysis | https://contoso.sharepoint.com/sites/site2 |

> [!important]
> Make sure your target libraries & sites contained in the file do exist in SharePoint Online.

# [PnP PowerShell](#tab/pnpps2)

```powershell
#Config Variables
$CSVFilePath = "C:\Temp\Folders.csv"

Try { 
    # Get the CSV file
    $CSVFile = Import-Csv $CSVFilePath
  
    # Read CSV file and create folders
    ForEach($Row in $CSVFile)
    {
        $SiteURL = $Row.SiteUrl
        
        # Connect to PnP Online
        Connect-PnPOnline -Url $SiteURL -Interactive
        $Web = Get-PnPWeb
        
        # Get the Document Library and its site relative URL
        $Library = Get-PnPList -Identity $Row.libName -Includes RootFolder
        
        If($Web.ServerRelativeUrl -eq "/")
        {
            $LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl
        }
        else
        {
            $LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl.Replace($Web.ServerRelativeUrl,'')
        }
        
        # Replace Invalid Characters from Folder Name, If any
        $FolderName = $Row.folderName
        $FolderName = [RegEx]::Replace($FolderName, "[{0}]" -f ([RegEx]::Escape([String]'\"*:<>?/\|')), '_')
 
        # Frame the Folder Name
        $FolderURL = $LibrarySiteRelativeURL+"/"+$FolderName
 
        # Create Folder if it doesn't exist
        Resolve-PnPFolder -SiteRelativePath $FolderURL | Out-Null
        Write-host "Ensured Folder:"$FolderName -f Green
    }
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
# Location of the CSV file
$CSVFilePath= "D:\dtemp\Folders.csv"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

Try {
    # Get the CSV file
    $CSVFile = Import-Csv $CSVFilePath
  
    # Read CSV file and create folders
    ForEach($Row in $CSVFile)
    {
		$SiteURL = $Row.SiteUrl
		
        # Get the Document Library and its site relative URL
		$Library = m365 spo list get --webUrl $SiteURL --title $Row.libName --properties "Title,Id,RootFolder/ServerRelativeUrl" | ConvertFrom-Json
		$LibrarySiteRelativeURL = $Library.RootFolder.ServerRelativeUrl

        # Replace Invalid Characters from Folder Name, If any
        $FolderName = $Row.folderName
        $FolderName = [RegEx]::Replace($FolderName, "[{0}]" -f ([RegEx]::Escape([String]'\"*:<>?/\|')), '_')
 
        # Create Folder if it doesn't exist
		m365 spo folder add --webUrl $SiteURL --parentFolderUrl $LibrarySiteRelativeURL --name $FolderName
        Write-host "Folder Created: "$FolderName -f Green
    }
}
catch {
    write-host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Jiten Parmar](https://github.com/jitenparmar) |
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-add-multiple-folders-in-libraries-using-csv-file" aria-hidden="true" />
