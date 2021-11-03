# Script for reporting the information from the samples

## Variables
param(
    [string]$BaseDir = "C:\Git\contrib\script-samples\",
    [string]$ScriptFolder = "scripts",
    [string]$ReportFile = "matrix.md",
    [string]$AssetsFolder = "assets"
)

function DispTick{
    [CmdletBinding()]
    param (
        [Parameter()]
        [bool]
        $in
    )

    if($in -eq $true){
        return "`u{1F44D}"
    }

    return "-"
}

function ResolveLink{
    param (
        [string]
        $Link
    )

    $markdownLink = "../scripts/{0}/README.md" -f $Link
    return $markdownLink
}

function GetTitleFromSampleJson{
    param(
        [string]$SamplePath,
        [string]$DefaultReturn
    )

    try{
        $assetsFolder = Join-Path -Path $SamplePath -ChildPath $AssetsFolder
        $sampleFilePath = Join-Path -Path $assetsFolder -ChildPath "sample.json"

        $json = Get-Content $sampleFilePath | ConvertFrom-Json

        return $json.title

    }catch{
        # Swallow - this shouldnt happen
        Write-Host "Warning cannot resolve title: $PSItem.Message"
    }

    return $DefaultReturn
}

# Check all pages for tabs and three ***

$dir = Join-Path -Path $BaseDir -ChildPath $ScriptFolder

$files = Get-ChildItem -Path $dir -Recurse -Include README.md

Write-Host "$($files.Length) found"

"# Matrix of Sample Distribution by Tool"  | Out-File $ReportFile -Force
"| Sample | PnP<br />PowerShell | Cli for Microsoft 365<br />PowerShell | Cli for Microsoft 365<br />Bash | Graph<br />SDK | SPO Management<br />Shell |" | Out-File $reportFile -Append
"|------|:--------:|:--------:|:----------:|:-----------:|:--------:|"  | Out-File $reportFile -Append

$matrixRows = @()
$sampleCount = 0

$PnPPSCount = 0
$CLIPSCount = 0
$CLIBashCount = 0
$GraphSDKCount = 0
$SPOMSCount = 0

$files | Foreach-Object {

    # Skip these
    if($_.Directory.Name -eq "scripts" -or
        $_.Directory.Name -eq "_template-script-submission"){
        return
    }

    $content = Get-Content -Path $_.FullName -Raw
    $title = GetTitleFromSampleJson -SamplePath $_.Directory -DefaultReturn $_.Directory.Name
    $dirName = $_.Directory.Name 
    $PnPPS = $false
    $CLIPS = $false
    $CLIBash = $false
    $GraphSDK = $false
    $SPOMS = $false


    #Write-Host $content
    if($content.Contains("#tab/pnpps")){  
        $PnPPS = $true
        $sampleCount++
        $PnPPSCount++
    }
    if($content.Contains("#tab/cli-m365-ps")){  
        $CLIPS = $true  
        $sampleCount++
        $CLIPSCount++
    }
    if($content.Contains("#tab/cli-m365-bash") -or
        $content.Contains("#tab/m365cli-bash")){ 
        
        $CLIBash = $true 
        $sampleCount++
        $CLIBashCount++
    }

    if($content.Contains("#tab/graphps")){ 
        $GraphSDK = $true
        $sampleCount++
        $GraphSDKCount++
    }  
    if($content.Contains("#tab/spoms-ps")){ 
        $SPOMS = $true
        $sampleCount++
        $SPOMSCount++
    }
    
    $status = [PSCustomObject]@{
        Link = "[$($title)]($(ResolveLink $dirName))"
        PnPPS = $PnPPS
        CLIPS = $CLIPS
        CLIBash = $CLIBash
        GraphSDK = $GraphSDK
        SPOMS = $SPOMS
    }
    $matrixRows += $status
}

# Output Report


$matrixRows | ForEach-Object{

    $row = "| {0} | {1} | {2} | {3} | {4} | {5} |" -f $_.Link, (DispTick $_.PnPPS), (DispTick $_.CLIPS), (DispTick $_.CLIBash), (DispTick $_.GraphSDK), (DispTick $_.SPOMS)
    Write-Host $row

    $row | Out-File $reportFile -Append
}

# Counts
$row = "| - | {0} | {1} | {2} | {3} | {4} |" -f $PnPPSCount, $CLIPSCount, $CLIBashCount, $GraphSDKCount, $SPOMSCount
$row | Out-File $reportFile -Append


"`nThere are **{0}** scenarios and **{1}** scripts in the site | Generated: {2} `n`n" -f $matrixRows.Length, $sampleCount, [System.DateTime]::Now.ToString("dd MMM yyyy hh:mm:ss") `
    | Out-File $reportFile -Append

"`rPnP PowerShell: {0} <br />Cli for Microsoft 365 PowerShell: {1}<br />Cli for Microsoft 365 Bash: {2}<br />Graph SDK: {3}<br />SPO Management SDK: {4}<br /><br />" `
    -f $PnPPSCount, $CLIPSCount, $CLIBashCount, $GraphSDKCount, $SPOMSCount `
    | Out-File $reportFile -Append