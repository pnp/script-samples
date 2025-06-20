
# Restore multiple deleted items from the SharePoint Online Recycle Bin based on deletion date and user name

## Summary

This PowerShell script is designed to help SharePoint Online administrators to restore items from the recycle bin that were deleted by a specific account (such as "System Account" or a SharePoint App) within a user-defined number of days.



## Scenario

Sometimes, there's a need to restore files that were accidentally deleted by users. One common scenario is when a user deletes a synced SharePoint folder without properly disconnecting it first.

## Requirements

To run this PowerShell script successfully, ensure the following:

1. PowerShell Version: [PowerShell 7 or later](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5)
2. PnP PowerShell Module: Installed and imported [(Install-Module PnP.PowerShell)](https://pnp.github.io/powershell/articles/installation.html)
3. [App-Only Authentication](https://github.com/pnp/PnP-PowerShell/tree/master/Samples/SharePoint.ConnectUsingAppPermissions): You must have:
    + A registered Azure AD App with appropriate SharePoint permissions
    + A valid Client ID
    + A certificate installed locally with its thumbprint
4. SharePoint Online Access: The app must have access to the target SharePoint site
5. Log Directory: The specified log directory must exist on the local machine

[More about Restore-PnPRecycleBinItem](https://pnp.github.io/powershell/cmdlets/Restore-PnPRecycleBinItem.html)

# [PnP PowerShell](#tab/pnpps)

```powershell

function Get-UserInput {
    [CmdletBinding()]
    param ()

    try {
        $inputData = [ordered]@{}
        $inputData["siteURL"] = Read-Host "Enter the SharePoint site URL (e.g., https://yourtenant.sharepoint.com/sites/demo)"
        $inputData["tenant"] = Read-Host "Enter your tenant domain (e.g., yourtenant.onmicrosoft.com)"
        $inputData["clientID"] = Read-Host "Enter the Azure AD App Client ID"
        $inputData["thumbprint"] = Read-Host "Enter the certificate thumbprint"
        $inputData["deletedByName"] = Read-Host "Enter the name of the account that deleted the items (e.g., System Account)"
        $inputData["logLocation"] = Read-Host "Enter the full path to the log directory (e.g., C:\Temp\Logs)"
        $inputData["numberOfDays"] = Read-Host "Enter the number of days to look back for deleted items"     

        return $inputData
    } catch {
        Write-Error "Error collecting user input: $_"
        exit 1
    }
}

function Test-LogDirectoryPath {
    param ([string]$Path)
    try {
        if (-not (Test-Path -Path $Path)) {
            throw "Log directory does not exist: $Path"
        }
        Write-Host "Log directory exists: $Path"
    } catch {
        Write-Error "Log directory validation failed: $_"
        exit 1
    }
}

function Connect-ToSharePoint {
    param (
        [string]$Tenant,
        [string]$ClientID,
        [string]$Thumbprint,
        [string]$SiteURL
    )
    try {
        Connect-PnPOnline -Tenant $Tenant -ClientId $ClientID -Thumbprint $Thumbprint -Url $SiteURL
        Write-Host "Connected to SharePoint site: $SiteURL"
    } catch {
        Write-Error "Failed to connect to SharePoint: $_"
        exit 1
    }
}

function Restore-RecycleBinItems {
    param (
        [string]$DeletedByName,
        [datetime]$TargetDate,
        [int]$BatchSize,
        [string]$LogFile
    )

    try {
        $count = 0
        Write-Host "Retrieving items deleted by '$DeletedByName' since $TargetDate..."
        $items = Get-PnPRecycleBinItem -RowLimit $BatchSize | Where-Object {
            $_.DeletedByName -eq $DeletedByName -and $_.DeletedDate -gt $TargetDate
        }

        foreach ($item in $items) {
            $count++
            Write-Host "$($item.Id) :::: $($item.Title) :::: $($item.ItemType) :::: $($item.DirName)"
            try {
                # Comment the next line if you want to skip the restoration and just log the items
                Restore-PnPRecycleBinItem -Identity $item.ID -Force

                
                $logEntry = "$count. Deleted Date: $($item.DeletedDate) ::  Restored item: $($item.Title) from $($item.DirName)"
                Write-Host $logEntry
                $logEntry | Out-File -FilePath $LogFile -Append
            } catch {
                $errorEntry = "$count. Deleted Date: $($item.DeletedDate) :: Failed to restore item: $($item.Title) - $_"
                Write-Warning $errorEntry
                $errorEntry | Out-File -FilePath $LogFile -Append
            }
        }

        Write-Host "Restoration process completed"
    } catch {
        Write-Error "Error during recycle bin item restoration: $_"
        exit 1
    }
}

# === MAIN EXECUTION ===

try {
    $userInput = Get-UserInput

    $batchSize = 999999
    $timeStamp = Get-Date -Format "yyyy-MM-dd-HHmmss"
    $targetDate = (Get-Date).AddDays(-[int]$userInput.numberOfDays).Date
    $logFileName = Join-Path -Path $userInput.logLocation -ChildPath "RestoreFile_$timeStamp.txt"

    Test-LogDirectoryPath -Path $userInput.logLocation
    Connect-ToSharePoint -Tenant $userInput.tenant -ClientID $userInput.clientID -Thumbprint $userInput.thumbprint -SiteURL $userInput.siteURL
    Restore-RecycleBinItems -DeletedByName $userInput.deletedByName -TargetDate $targetDate -BatchSize $batchSize -LogFile $logFileName
} catch {
    Write-Error "Unexpected error occurred: $_"
    exit 1
} finally {
    try {
        Disconnect-PnPOnline
        Write-Host "Disconnected from SharePoint."
    } catch {
        Write-Warning "Failed to disconnect from SharePoint: $_"
    }
}
# End of script
```


## Contributors

| Author(s) |
|-----------|
| Pankaj Badoni |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-restore-multiple-items" aria-hidden="true" />
