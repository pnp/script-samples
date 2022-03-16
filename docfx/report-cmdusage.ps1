# Script for reporting the information from the samples

## Variables
param(
    [string]$BaseDir = "C:\Git\contrib\script-samples\",
    [string]$ScriptFolder = "scripts",
    [string]$ReportFile = "cmdusage.md",
    [string]$AssetsFolder = "assets",
    [string]$DocFxFolder = "docfx",
    [string]$HelpFolder = "help",
    [string]$IgnoreFile = "ignore.help.json"
)

function ResolveLink{
    param (
        [string]
        $Link
    )

    $markdownLink = Join-Path "../" "scripts" $Link "README.md"
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

$dir = Join-Path $BaseDir $ScriptFolder

$files = Get-ChildItem -Path $dir -Recurse -Include README.md

Write-Host "$($files.Length) found"

"# Report of Samples Command Usage"  | Out-File $ReportFile -Force
"| Sample | Cmdlets | Detected Cmdlets |" | Out-File $reportFile -Append
"|--------|:--------:|:--------:|"  | Out-File $reportFile -Append

$matrixRows = @()
$helpCmds = @()
$cmdUsage = @()
$sampleCount = 0

# Get all help files in memory
$helpFolderPath = Join-Path $BaseDir $DocFxFolder $AssetsFolder $HelpFolder

Write-Host "Help Path: $helpFolderPath"

$helpFiles = Get-ChildItem -Path $helpFolderPath -Recurse -Include *.json
$helpFiles | ForEach-Object {
    
    $cmds = Get-Content -Path $_.FullName -Raw | ConvertFrom-Json

    $helpCmds += $cmds

    Write-Host "Help File: $_.Name Loaded"

    $cmdUsage += [PSCustomObject]@{
        File = $_.Name
        Cmdlets = $cmds | ForEach-Object {
            [PSCustomObject]@{ 
                Command = $_.cmd
                UsageCount = 0
            }
        }
    }
}

# Load the exceptions list
$ignoreFile = Join-Path $helpFolderPath $IgnoreFile
$ignoreHelpCmds = Get-Content -Path $ignoreFile -Raw | ConvertFrom-Json | ForEach-Object { "{0}," -f $_.cmd }

Write-Host "Commands for Help Loaded: $($helpCmds.Length)"
Write-Host "Commands for Count Loaded: $($cmdUsage.Length)"
Write-Host "Commands Ignored: $($ignoreHelpCmds)"

$files | Foreach-Object {

    # Skip these
    if($_.Directory.Name -eq "scripts" -or
        $_.Directory.Name -eq "_template-script-submission"){
        return
    }

    $content = GetReadme -SamplePath $_.Directory
    $title = GetTitleFromSampleJson -SamplePath $_.Directory -DefaultReturn $_.Directory.Name
    $dirName = $_.Directory.Name
    $cmdletsUsed = ""
    $detectCmds = ""

    # TODO: This can be optimised to reduce the processing time
    $helpCmds | foreach-Object {
        if($content.Contains($_.cmd) -and $_.cmd -ne ""){
            $cmdletsUsed += "{0}, " -f $_.cmd

            $findCmd = $_.cmd
            # Cmdlet Usage
            $cmdUsage | ForEach-Object{
                
                $existingCmd = $_.Cmdlets | Where-Object { $_.Command -eq $findCmd }
                if($existingCmd){
                    if($existingCmd.Length -eq 1){
                        $existingCmd.UsageCount += 1
                    }
                    if($existingCmd.Length -gt 1){
                        Write-Host "Warning: more than one cmdlet found for {0}" -f $findCmd
                    }
                }
            }
        }
    }

    # Find all PowerShell commands beyond the help content
    $results = $content | Select-String "\s[A-Za-z]+\-[A-Za-z]+\s" -AllMatches
    $results.Matches | ForEach-Object { 
        [regex]::Escape($_.Value).Replace("\n","").Replace("\t","").Replace("\r","").replace("\ ","") 
    } | ForEach-Object {
        
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

# show cmdlets NOT used

# PnP PowerShell
"## Overview of Sample Command Usage"  | Out-File $ReportFile -Append

$cmdUsage | ForEach-Object{

    if($_.File -ne "ignore.help.json" -and $_.File -ne "archive.help.json"){

        $friendlyName = ""
        switch ($_.File) {
            "cli.help.json" { $friendlyName = "CLI for Microsoft 365" }
            "powershell.help.json" { $friendlyName = "PnP PowerShell" }
            "spoms.help.json" { $friendlyName = "SharePoint Online Management Shell" }
            Default {}
        }


        "### $($friendlyName) Usage"  | Out-File $ReportFile -Append

        "| Used Cmdlets | Unused Cmdlets |" | Out-File $reportFile -Append
        "|--------|--------|"  | Out-File $reportFile -Append
    
        $usedCommands = $_.Cmdlets | Where-Object { $_.UsageCount -gt 0 } 
        $unUsedCommands = $_.Cmdlets | Where-Object { $_.UsageCount -eq 0 }

        $usedResult = ""
        $usedCommands | ForEach-Object { 
            $usedResult += "{0}<br />" -f $_.Command 
        }

        $unUsedResult = ""
        $unUsedCommands | ForEach-Object { 
            $UnUsedResult += "{0}<br />" -f $_.Command 
        }

        $row = "| {0} | {1} |" -f $usedResult, $UnUsedResult
        Write-Host $row

        $row | Out-File $reportFile -Append

    }   
}


$summary = "`nThere are **{0}** script scenarios with metadata in the site | Generated: {1} `n`n" -f $sampleCount, [System.DateTime]::Now.ToString("dd MMM yyyy hh:mm:ss")
Write-Host $summary
$summary | Out-File $reportFile -Append