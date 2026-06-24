# Generate File version report and trim on specific Teams

## Summary

This script helps you **report on and trim file version history** across multiple Microsoft Teams sites (including private channels) to reclaim SharePoint storage. It is not designed to run from start to end in one go — it is organized into **sequential blocks** that you execute step by step, with an optional batching mechanism for large-scale environments.

### Script blocks (must be run in order)

| Block | Purpose |
|-------|---------|
| **Login** | Establishes a PnP connection using your chosen credentials (interactive, app registration, etc.). The same connection object is reused across blocks. |
| **Report Block** | Iterates over a list of M365 group names. For each group it resolves the main Teams site and all associated private channel sites, collecting owners, document libraries, storage usage, and current auto-expiration policy into a `$result` array. |
| **Batch variables** *(optional)* | Splits `$result` into fixed-size batches (e.g. `$batch1`, `$batch2`) so you can process a large number of sites incrementally instead of all at once. |
| **Site Version Report Job** | For every site in `$result` (or a batch), creates a hidden `StorageReport` document library and triggers `New-PnPSiteFileVersionExpirationReportJob` — an async SharePoint job that writes a CSV listing all file versions eligible for expiry. Once completed, the CSV is downloaded locally. A `$reportMode` flag lets you check job status without starting new jobs. |
| **Sum of Storage Savings** | Reads all downloaded CSVs and sums the bytes for versions whose `AutomaticPolicyExpirationDate` is in the past — giving you the total storage that would be freed before you commit to deletion. |
| **Site Version Deletion** | For every site, triggers `New-PnPSiteFileVersionBatchDeleteJob -Automatic` to delete expired versions and then sets the site to automatic versioning via `Set-PnPSiteVersionPolicy`. The same `$reportMode` flag is used here as a safety gate: set it to `$false` only when you are ready to delete. |

### Important: user context requirement

`New-PnPSiteFileVersionExpirationReportJob` and `New-PnPSiteFileVersionBatchDeleteJob` **must be triggered in a delegated (user) context** — they do not work with app-only authentication. All other blocks can run with an app registration. A practical split is:

- **App registration** (high tenant privileges): Login, Report Block, Batch variables, Sum block
- **SPO admin user / service account** (with access to all target sites): Site Version Report Job block, Site Version Deletion block

For simplicity, the script is written to use a single connection throughout — adapt the Login block credentials accordingly for your environment.

# [PnP PowerShell](#tab/pnpps)

```powershell
#### LOGIN BLOCK
# set creds to $Creds
$Creds = @{
    Interactive = $true
    ClientId    = "6e0b566f-bb83-44b0-86fa-013dd60c383d"
}
$cn = Connect-PnPOnline @Creds -ReturnConnection
# -> Describe what permissions are needed
#### END LOGIN BLOCK

### START REPORT BLOCK
$teamsByM365GroupName = @("My Team1","My Team2")
$result = @()

foreach ($teamName in $teamsByM365GroupName) {

   Write-Host "Processing $teamName..." -ForegroundColor Cyan

   # 1. Get M365 Group
   $group = Get-PnPMicrosoft365Group -Identity $teamName -IncludeSiteUrl  -Connection $cn

   if (!$group) {
       Write-Warning "Group not found: $teamName"
       continue
   }

   # 2. Get Group Owners
   $owners = Get-PnPMicrosoft365GroupOwner -Identity $group.Id -Connection $cn

   # 3. Get Main SharePoint Site (General channel)
   $mainSiteUrl = $group.SiteUrl

   # 4. Get Team + Channels
   $team = Get-PnPTeamsTeam -Identity $group.Id -Connection $cn
   $channels = Get-PnPTeamsChannel -Team $team -Connection $cn

   # Filter private channels
   $privateChannels = $channels | Where-Object {$_.MembershipType -eq "private"}

   $primaryChannel = Get-PnPTeamsPrimaryChannel -Team $team -Connection $cn

   $tenantSite = Get-PnPTenantSite -Url $mainSiteUrl -Connection $cn -Detailed | Select Url, StorageUsageCurrent, EnableAutoExpirationVersionTrim

   $cnSite = Connect-PnPOnline -Url $mainSiteUrl @Creds -ReturnConnection

   $docLibs = Get-PnPList -Connection $cnSite | Where-Object {
       $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false
   }

   $result += [PSCustomObject]@{
       TeamName                = $team.DisplayName
       GroupId                 = $group.Id
       MainSiteUrl             = $mainSiteUrl
       GroupOwners             = ($owners.UserPrincipalName -join ";")
       ChannelType             = "Default"
       ChannelName             = $primaryChannel.DisplayName
       ChannelSite             = $mainSiteUrl
       ChannelOwners           = ($owners.UserPrincipalName -join ";")
       ChannelDocLibs          = ($docLibs.Title -join ";")
       ChannelStorageUsage     = $tenantSite.StorageUsageCurrent # in MB -> / 1024 for GB
       ChannelAutoExpiration   = $tenantSite.EnableAutoExpirationVersionTrim
   }

   foreach ($channel in $privateChannels) {

       Write-Host "Processing Private Channel $($channel.DisplayName)..." -ForegroundColor Cyan

       # 5. Get Private Channel SPO Site URL
       # Pattern: https://tenant.sharepoint.com/sites/<GroupName>-<ChannelName>
       # Better: resolve via PnP

       $channelSite = Get-PnPTeamsChannelFilesFolder -Team $team -Channel $channel -Connection $cn

       # 6. Get Private Channel Owners
       $channelOwners = Get-PnPTeamsChannelUser -Team $team -Channel $channel -Role Owner -Connection $cn

       $channelSite = $($channelSite.webUrl.split("/")[0..4] -join "/")

       $tenantSite = Get-PnPTenantSite -Url $channelSite -Connection $cn -Detailed | Select Url, StorageUsageCurrent, EnableAutoExpirationVersionTrim

       $cnSite = Connect-PnPOnline -Url $channelSite @Creds -ReturnConnection

       $docLibs = Get-PnPList -Connection $cnSite | Where-Object {
           $_.BaseTemplate -eq 101 -and $_.Hidden -eq $false
       }

       $result += [PSCustomObject]@{
           TeamName                = $team.DisplayName
           GroupId                 = $group.Id
           MainSiteUrl             = $mainSiteUrl
           GroupOwners             = ($owners.UserPrincipalName -join ";")
           ChannelType             = "Private"
           ChannelName             = $channel.DisplayName
           ChannelSite             = $channelSite
           ChannelOwners           = ($channelOwners.Email -join ";")
           ChannelDocLibs          = ($docLibs.Title -join ";")
           ChannelStorageUsage     = $tenantSite.StorageUsageCurrent # in MB -> / 1024 for GB
           ChannelAutoExpiration   = $tenantSite.EnableAutoExpirationVersionTrim
       }
   }
}

$result

### END REPORT BLOCK

### IF BATCHES ARE NEEDED
$batchSize = 20

for ($start = 0; $start -lt $result.Count; $start += $batchSize) {
   $batchNumber = [int]($start / $batchSize) + 1
   $end = [Math]::Min($start + $batchSize - 1, $result.Count - 1)

   Set-Variable -Name "batch$batchNumber" -Value $result[$start..$end]
}

### START SITE VERSION REPORT JOB BLOCK

$reportMode = $true  #to check job status only
#$reportMode = $false #to start new report jobs

foreach($c in $result){
#foreach($c in $batch1){

   $cnSite = Connect-PnPOnline -Url $c.ChannelSite @Creds -ReturnConnection

   $list = Get-PnPList -Identity "StorageReport" -Connection $cnSite -ErrorAction SilentlyContinue

   if (-not $list) {
       New-PnPList -Title "StorageReport" -Template DocumentLibrary -OnQuickLaunch:$false -Connection $cnSite
       Set-PnPList -Identity "StorageReport" -Hidden:$true -NoCrawl:$true -BreakRoleInheritance:$true -CopyRoleAssignments:$false -Connection $cnSite
   }

   $reportUrl = "$($c.ChannelSite)/StorageReport/SiteVersionReport_$($c.ChannelSite.Split('/')[-1]).csv"
   $status = Get-PnPSiteFileVersionExpirationReportJobStatus -ReportUrl $reportUrl -Connection $cnSite -ErrorAction SilentlyContinue

   if ((-not $status -or $status.Status -in @("no_report_found")) -and $reportMode -eq $false){
       New-PnPSiteFileVersionExpirationReportJob -ReportUrl $reportUrl -Connection $cnSite
   }
   else {
       Write-Host "Report $reportUrl in Status $($status.Status)"
   }

   if($status.Status -eq "completed"){
       $tenantBaseUrl = "$([Uri]::new($c.ChannelSite).Scheme)://$([Uri]::new($c.ChannelSite).Host)"
       $siteName = $c.ChannelSite.Split('/')[-1]
       Get-PnPFile -Url "$($c.ChannelSite.Replace($tenantBaseUrl,''))/StorageReport/SiteVersionReport_$siteName.csv" -AsFile -Path "." -Filename "SiteVersionReport_$siteName.csv" -Force -Connection $cnSite
   }
}
### END SITE VERSION REPORT JOB BLOCK

### START GET SUM OF STORAGE SAVINGS BLOCK
$now = Get-Date
 
$batchResult = Get-ChildItem -Path "." -Filter *.csv | ForEach-Object {
 
$sumBytes = Import-Csv $_.FullName |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_.AutomaticPolicyExpirationDate) -and
            ([datetime]$_.AutomaticPolicyExpirationDate -lt $now)
        } |
        Measure-Object -Property Size -Sum |
        Select-Object -ExpandProperty Sum
 
    $sumMB = [math]::Round(($sumBytes / 1048576), 2)
 
    [PSCustomObject]@{
        FileName = $_.Name
        ExpiredSizeMB = $sumMB
    }
}
 
$batchResult
($batchResult | Measure-Object -Property ExpiredSizeMB -Sum).Sum
### END GET SUM OF STORAGE SAVINGS BLOCK

### START SITE VERSION DELETION

$reportMode = $true #to get job status only
#$reportMode = $false #to start the job

foreach($c in $result){
#foreach($c in $batch1){

   $cnSite = Connect-PnPOnline -Url $c.ChannelSite @Creds -ReturnConnection

   $status = Get-PnPSiteFileVersionBatchDeleteJobStatus -Connection $cnSite -ErrorAction SilentlyContinue
   $status

   if ((-not $status -or $status.Status -eq "NoRequestFound") -and $reportMode -eq $false){
       New-PnPSiteFileVersionBatchDeleteJob -Automatic -Connection $cnSite
       Set-PnPSiteVersionPolicy -EnableAutoExpirationVersionTrim $true -Connection $cnSite
   }
   else {
       Write-Host "$($c.ChannelSite) - Site File Version Batch Delete Job in Status $($status.Status)"
   }
}

### END SITE VERSION DELETION
```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

***

## Contributors

| Author(s) |
|-----------|
| Fabian Hutzli |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-report-version-expiration-and-trim" aria-hidden="true" />
