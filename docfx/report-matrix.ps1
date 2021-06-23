# Script for reporting the information from the samples

## Variables
param(
    [string]$BaseDir = "C:\Git\contrib\script-samples\",
    [string]$ScriptFolder = "scripts",
    [string]$ReportFile = "matrix.md"
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

# Check all pages for tabs and three ***

$dir = Join-Path -Path $BaseDir -ChildPath $ScriptFolder

$files = Get-ChildItem -Path $dir -Recurse -Include README.md

Write-Host "$($files.Length) found"

"# Matrix of Sample Distribution by Tool"  | Out-File $ReportFile -Force
"| Sample | PnP<br />PowerShell | Cli for Microsoft 365<br />PowerShell | Cli for Microsoft 365<br />Bash | Graph<br />SDK | SPO Management<br />Shell |" | Out-File $reportFile -Append
"|------|:--------:|:--------:|:----------:|:-----------:|:--------:|"  | Out-File $reportFile -Append

$matrixRows = @()

$files | Foreach-Object {

    # Skip these
    if($_.Directory.Name -eq "scripts" -or
        $_.Directory.Name -eq "template-script-submission"){
        return
    }

    $content = Get-Content -Path $_.FullName -Raw
    $title = $_.Directory.Name
    $dirName = $_.Directory.Name 
    $PnPPS = $false
    $CLIPS = $false
    $CLIBash = $false
    $GraphSDK = $false
    $SPOMS = $false


    #Write-Host $content
    if($content.Contains("#tab/pnpps")){  $PnPPS = $true  }
    if($content.Contains("#tab/cli-m365-ps")){  $CLIPS = $true  }
    if($content.Contains("#tab/cli-m365-bash") -or
        $content.Contains("#tab/m365cli-bash")){ $CLIBash = $true }
    if($content.Contains("#tab/graphps")){ $GraphSDK = $true }  
    if($content.Contains("#tab/spoms-ps")){ $SPOMS = $true }
    
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

"`nThere are **{0}** samples in the site | Generated: {1} `n" -f $matrixRows.Length, [System.DateTime]::Now.ToString("dd MMM yyyy hh:mm:ss") `
    | Out-File $reportFile -Append

