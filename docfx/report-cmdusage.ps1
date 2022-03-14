# Script for reporting the information from the samples

## Variables
param(
    [string]$BaseDir = "C:\Git\contrib\script-samples\",
    [string]$ScriptFolder = "scripts",
    [string]$ReportFile = "cmd-usage.md",
    [string]$AssetsFolder = "assets",
    [string]$HelpCmdletsFolder = "/docfx/assets/help",
    [string]$IgnoreFile = "ignore.help.json"
)

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

function GetReadme{
    param(
        [string]$SamplePath
    )

    try{
        
        $readmeFilePath = Join-Path -Path $SamplePath -ChildPath "README.md"

        $content = Get-Content $readmeFilePath -Raw

        return $content

    }catch{
        # Swallow - this shouldnt happen
        Write-Host "Warning cannot resolve readme: $PSItem.Message"
    }
}


# Check all pages for tabs and three ***

$dir = Join-Path -Path $BaseDir -ChildPath $ScriptFolder

$files = Get-ChildItem -Path $dir -Recurse -Include README.md

Write-Host "$($files.Length) found"

"# Metadata Report of Samples"  | Out-File $ReportFile -Force
"| Sample | Cmdlets | Detected Cmdlets |" | Out-File $reportFile -Append
"|--------|:--------:|:--------:|"  | Out-File $reportFile -Append

$matrixRows = @()
$helpCmds = @()
$sampleCount = 0

# Get all help files in memory
$helpFolder = Join-Path -Path $BaseDir -ChildPath $HelpCmdletsFolder
$helpFiles = Get-ChildItem -Path $helpFolder -Recurse -Include *.json
$helpFiles | ForEach-Object {
    
    $helpCmds += Get-Content -Path $_.FullName -Raw | ConvertFrom-Json
}

# Load the exceptions list
$ignoreFile = "{0}/{1}/{2}" -f (Get-Location), "assets/help", $IgnoreFile
$ignoreHelpCmds = Get-Content -Path $ignoreFile -Raw | ConvertFrom-Json | % { "{0}," -f $_.cmd }

Write-Host "Commands Loaded: $($helpCmds.length)"
Write-Host "Commands Ignored: $($ignoreHelpCmds)"


$files | Foreach-Object {

    # Skip these
    if($_.Directory.Name -eq "scripts" -or
        $_.Directory.Name -eq "_template-script-submission"){
        return
    }

    $content = GetReadme -SamplePath $_.Directory
    $title = GetTitleFromSampleJson -SamplePath $_.Directory -DefaultReturn $_.Directory.Name


    $cmdletsUsed = ""
    $detectCmds = ""

    $helpCmds | foreach-Object {
        if($content.Contains($_.cmd) -and $_.cmd -ne ""){
            $cmdletsUsed += "{0}, " -f $_.cmd
        }
    }

    # Find all PowerShell commands beyond the help content
    $results = $content | Select-String "\s[A-Za-z]+\-[A-Za-z]+\s" -AllMatches
    $results.Matches | %  { [regex]::Escape($_.Value).Replace("\n","").Replace("\t","").Replace("\r","").replace("\ ","") } | % {
        
        # Do not report on ignored cmdlets and already listed commands
        if(!$ignoreHelpCmds.Contains( $_) -and !$cmdletsUsed.Contains($_)){
            
            # De-deplicate
            if(!$detectCmds.Contains($_)){
                $detectCmds += "{0}, " -f $_
            }
        }
    }

    $sampleCount++
    
    $status = [PSCustomObject]@{
        Sample = "[$($title)]($(ResolveLink $dirName))"
        Cmdlets = $cmdletsUsed.TrimEnd(", ")
        DetectCmds = $detectCmds.TrimEnd(", ")
    }

    $matrixRows += $status
}

# Output Report


$matrixRows | ForEach-Object{

    $row = "| {0} | {1} | {2} |" -f $_.Sample, $_.Cmdlets, $_.DetectCmds
    Write-Host $row

    $row | Out-File $reportFile -Append
}

#cmdlets NOT used




$summary = "`nThere are **{0}** script scenarios with metadata in the site | Generated: {1} `n`n" -f $sampleCount, [System.DateTime]::Now.ToString("dd MMM yyyy hh:mm:ss")
Write-Host $summary
$summary | Out-File $reportFile -Append