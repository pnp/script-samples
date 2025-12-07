

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
function Add-DummySharePointContent {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, HelpMessage = "URL of the SharePoint site (e.g. https://contoso.sharepoint.com/sites/Company311)")]
        [ValidateNotNullOrEmpty()]
        [string]
        $SiteUrl,

        [Parameter(Mandatory, HelpMessage = "Site-relative URL of the document library (e.g. /Shared Documents)")]
        [ValidateNotNullOrEmpty()]
        [string]
        $LibraryServerRelativeUrl,

        [Parameter(Mandatory, HelpMessage = "Path to the local seed file that will be uploaded")]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]
        $LocalSeedFile,

        [Parameter(HelpMessage = "Number of folders to create")]
        [ValidateRange(1, 2000)]
        [int]
        $FolderCount = 50,

        [Parameter(HelpMessage = "Number of files to create within each folder")]
        [ValidateRange(1, 500)]
        [int]
        $FilesPerFolder = 10,

        [Parameter(HelpMessage = "Folder name prefix")]
        [ValidateNotNullOrEmpty()]
        [string]
        $FolderPrefix = "Folder"
    )

    begin {
        Write-Host "Ensuring Microsoft 365 CLI session..." -ForegroundColor Cyan
        $loginOutput = m365 login --ensure 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to ensure CLI login. CLI output: $loginOutput"
        }

        $seedFile = Get-Item -LiteralPath $LocalSeedFile -ErrorAction Stop

        $script:Summary = [ordered]@{
            FoldersRequested = $FolderCount
            FilesRequested   = $FolderCount * $FilesPerFolder
            FoldersCreated   = 0
            FoldersSkipped   = 0
            FilesUploaded    = 0
            FilesSkipped     = 0
            Failures         = 0
        }

        $script:Report = New-Object System.Collections.Generic.List[object]
        $script:ReportPath = Join-Path -Path (Get-Location) -ChildPath ("dummy-content-report-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
    }

    process {
        for ($folderIndex = 1; $folderIndex -le $FolderCount; $folderIndex++) {
            $folderName = "{0}_{1}" -f $FolderPrefix, $folderIndex
            $folderDisplayPath = "$LibraryServerRelativeUrl/$folderName"

            if (-not $PSCmdlet.ShouldProcess($folderDisplayPath, "Create folder")) {
                $script:Summary.FoldersSkipped++
                $script:Report.Add([pscustomobject]@{
                    ItemType   = 'Folder'
                    Name       = $folderName
                    Path       = $folderDisplayPath
                    Status     = 'Skipped'
                    Note       = 'WhatIf'
                })
                continue
            }

            $folderOutput = m365 spo folder add --webUrl $SiteUrl --parentFolderUrl $LibraryServerRelativeUrl --name $folderName --output json 2>&1
            if ($LASTEXITCODE -ne 0) {
                $script:Summary.Failures++
                Write-Warning "Failed to create folder '$folderName'. CLI output: $folderOutput"
            }
            else {
                $script:Summary.FoldersCreated++
            }

            $script:Report.Add([pscustomobject]@{
                ItemType   = 'Folder'
                Name       = $folderName
                Path       = $folderDisplayPath
                Status     = if ($LASTEXITCODE -eq 0) { 'Created' } else { 'Failed' }
                Note       = if ($LASTEXITCODE -eq 0) { '' } else { $folderOutput }
            })

            for ($fileIndex = 1; $fileIndex -le $FilesPerFolder; $fileIndex++) {
                $newFileName = "{0}_{1}{2}" -f $seedFile.BaseName, $fileIndex, $seedFile.Extension
                $targetFolder = "$LibraryServerRelativeUrl/$folderName"

                if (-not $PSCmdlet.ShouldProcess("$targetFolder/$newFileName", "Upload file")) {
                    $script:Summary.FilesSkipped++
                    $script:Report.Add([pscustomobject]@{
                        ItemType   = 'File'
                        Name       = $newFileName
                        Path       = "$targetFolder/$newFileName"
                        Status     = 'Skipped'
                        Note       = 'WhatIf'
                    })
                    continue
                }

                $fileOutput = m365 spo file add --webUrl $SiteUrl --folder $targetFolder --path $seedFile.FullName --fileName $newFileName --output json 2>&1
                if ($LASTEXITCODE -ne 0) {
                    $script:Summary.Failures++
                    Write-Warning "Failed to upload file '$newFileName'. CLI output: $fileOutput"
                }
                else {
                    $script:Summary.FilesUploaded++
                }

                $script:Report.Add([pscustomobject]@{
                    ItemType   = 'File'
                    Name       = $newFileName
                    Path       = "$targetFolder/$newFileName"
                    Status     = if ($LASTEXITCODE -eq 0) { 'Uploaded' } else { 'Failed' }
                    Note       = if ($LASTEXITCODE -eq 0) { '' } else { $fileOutput }
                })
            }
        }
    }

    end {
        try {
            $script:Report | Export-Csv -Path $script:ReportPath -NoTypeInformation -Encoding UTF8
            Write-Host "Report saved to $($script:ReportPath)." -ForegroundColor Green
        }
        catch {
            $script:Summary.Failures++
            Write-Error "Failed to write report: $($_.Exception.Message)"
        }

        Write-Host "----- Summary -----" -ForegroundColor Cyan
        Write-Host "Folders requested : $($script:Summary.FoldersRequested)"
        Write-Host "Folders created   : $($script:Summary.FoldersCreated)"
        Write-Host "Folders skipped   : $($script:Summary.FoldersSkipped)"
        Write-Host "Files requested   : $($script:Summary.FilesRequested)"
        Write-Host "Files uploaded    : $($script:Summary.FilesUploaded)"
        Write-Host "Files skipped     : $($script:Summary.FilesSkipped)"
        Write-Host "Failures          : $($script:Summary.Failures)"

        if ($script:Summary.Failures -gt 0) {
            Write-Warning "Some operations failed. Review the report for details."
        }
    }
}

Add-DummySharePointContent -SiteUrl "https://contoso.sharepoint.com/sites/Company311" -LibraryServerRelativeUrl "/Shared Documents" -LocalSeedFile "D:\dtemp\TestDoc.docx" -FolderCount 100 -FilesPerFolder 10
```

[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]

***

## Contributors

| Author(s) |
|-----------|
| [Reshmee Auckloo](https://github.com/reshmee011)|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |
| [Reshmee Auckloo](https://github.com/reshmee011)|
| [Ganesh Sanap](https://ganeshsanapblogs.wordpress.com/about) |
| Adam Wójcik |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-add-dummy-folders-and-files" aria-hidden="true" />
