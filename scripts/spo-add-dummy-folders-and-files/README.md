---
plugin: add-to-gallery
---

# Add dummy folders and files to a SharePoint library

## Summary

This sample shows how to add dummy folders and files into a SharePoint document library. The script was used to generate files within folders to perform some testing.

## Implementation
 
1. Open Windows PowerShell ISE.
2. Create a new file, e.g. TestDoc.docx and save it to a file server location, e.g. C:/Temp.
3. A loop within another loop using `While` is used to create the number of specified files within each of the specified number of folders. 

# [PnP PowerShell](#tab/pnpps)

```powershell
# Parameters
$SiteURL = "https://contoso.sharepoint.com/sites/Company311"

# Library in which to create the dummy files and folders
$LibraryName = "LargeLibrary"

# Location of the dummy file
$LocalFile= "C:\Temp\TestDoc.docx"

# Number of files to create within each folder
$MaxFilesCount = 20

# Number of folders to create in the libraru
$MaxFolderCount = 500

# The name of the folder to be created
$FolderName  = "Folder"

Try {
    # Get the File from file server
    $File = Get-ChildItem $LocalFile

    # Connect to SharePoint online site
    Connect-PnPOnline -Url $SiteURL -Interactive

    # Initialize folder counter
    $FolderCounter = 1
    
    While($FolderCounter -le $MaxFolderCount)
    {
        $newFolderName = $FolderName + "_" + $FolderCounter
        Try {
            # Add new folder in the library
            Add-PnPFolder -Name $newFolderName -Folder "$($LibraryName)" | Out-Null
            Write-Host -f Green "New Folder '$newFolderName' Created ($FolderCounter of $MaxFolderCount)!"   
            
            # Initialize file counter
            $FileCounter = 1

            While($FileCounter -le $MaxFilesCount)
            {
                $NewFileName = $File.BaseName + "_" + $FileCounter + ".docx"
                Try {
                    # Add new file in the folder
                    Add-PnPFile -Path $File -Folder "$($LibraryName)/$newFolderName" -NewFileName $NewFileName | Out-Null
                }
                Catch {
                    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
                }
                Write-Host -f Green "New File '$NewFileName' Created ($FileCounter of $MaxFilesCount)!"
                $FileCounter++
            }
        }
        Catch {
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
        $FolderCounter++;
   }
}
Catch {
    Write-Host -f Red "Error Uploading File:"$_.Exception.Message
}
```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

# [CLI for Microsoft 365](#tab/cli-m365-ps)

```powershell
# SharePoint online site URL
$SiteURL = Read-Host -Prompt "Enter your SharePoint site URL (e.g https://contoso.sharepoint.com/sites/Company311)"

# Document library URL where you want to create the dummy folders and files 
$LibraryName = Read-Host -Prompt "Enter site-relative URL of your Document library (e.g '/Shared Documents')"

# Location of the dummy file
$LocalFile= "D:\dtemp\TestDoc.docx"

# Number of files to create within each folder
$MaxFilesCount = 20

# Number of folders to create in the libraru
$MaxFolderCount = 500

# The name of the folder to be created
$FolderName  = "Folder"

# Get Credentials to connect
$m365Status = m365 status
if ($m365Status -match "Logged Out") {
    m365 login
}

Try {
	# Get the File from file server
	$File = Get-ChildItem $LocalFile

	# Initialize folder counter
	$FolderCounter = 1
    
	While($FolderCounter -le $MaxFolderCount)
	{
		$newFolderName = $FolderName + "_" + $FolderCounter
		Try {
			# Add new folder in the library
			m365 spo folder add --webUrl $SiteURL --parentFolderUrl $LibraryName --name $newFolderName
			Write-Host -f Green "New Folder '$newFolderName' Created ($FolderCounter of $MaxFolderCount)!"   
			
			# Initialize file counter
			$FileCounter = 1
			
			While($FileCounter -le $MaxFilesCount)
			{
				$NewFileName = $File.BaseName + "_" + $FileCounter + ".docx"
				Try {
					# Add new file in the folder
					m365 spo file add --webUrl $SiteURL --folder "$($LibraryName)/$newFolderName" --path $File --FileLeafRef $NewFileName
				}
				Catch {
					Write-Host "Error while creating a new file: $($_.Exception.Message)" -ForegroundColor Red
				}
				Write-Host -f Green "New File '$NewFileName' Created ($FileCounter of $MaxFilesCount)!"
				$FileCounter++
		   }
		}
        Catch {
			Write-Host "Error while creating a new folder: $($_.Exception.Message)" -ForegroundColor Red
		}
		$FolderCounter++;
	}
}
Catch {
	write-host -f Red "Error Uploading File:"$_.Exception.Message
}

# Disconnect SharePoint online connection
m365 logout
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-add-dummy-folders-and-files" aria-hidden="true" />
