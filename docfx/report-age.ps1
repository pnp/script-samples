# Script for reporting the information from the samples

## Variables
param(
    [string]$BaseDir = "d:\contrib\pkb-script-samples\",
    [string]$ScriptFolder = "scripts",
    [string]$ReportFile = "age.md",
    [string]$AssetsFolder = "assets"
)

function ResolveLink{
    param (
        [string]
        $Link
    )

    $markdownLink = "../scripts/{0}/README.md" -f $Link
    return $markdownLink
}

function GetJsonFromSampleJson{
    param(
        [string]$SamplePath,
        [string]$DefaultReturn
    )

    try{
        $assetsFolder = Join-Path -Path $SamplePath -ChildPath $AssetsFolder
        $sampleFilePath = Join-Path -Path $assetsFolder -ChildPath "sample.json"

        $json = Get-Content $sampleFilePath | ConvertFrom-Json

        return $json

    }catch{
        # Swallow - this shouldnt happen
        Write-Host "Warning cannot resolve json: $PSItem.Message"
    }

    return $DefaultReturn
}

function ConvertToDateTime{
    param(
        [string]$DateTimeString
    )

    try{
        $dateTime = [System.DateTime]::Parse($DateTimeString)
    }catch{
        # Swallow - this shouldnt happen
        Write-Host "Warning cannot convert to DateTime: $PSItem.Message"
        return $null
    }

    return $dateTime
}

# Check all pages for tabs and three ***

$dir = Join-Path -Path $BaseDir -ChildPath $ScriptFolder

$files = Get-ChildItem -Path $dir -Recurse -Include README.md

Write-Host "$($files.Length) found"

"# Age Report of Samples"  | Out-File $ReportFile -Force
"| Sample | Created | Modified (Latest) |  " | Out-File $reportFile -Append
"|--------|:----:|:--------:|"  | Out-File $reportFile -Append

$matrixRows = @()
$sampleCount = 0

$files | Foreach-Object {

    # Skip these
    if($_.Directory.Name -eq "scripts" -or
        $_.Directory.Name -eq "_template-script-submission"){
        return
    }

    $sampleJsonObj = GetJsonFromSampleJson -SamplePath $_.Directory -DefaultReturn $_.Directory.Name

    $title = $sampleJsonObj.title
    $dirName = $_.Directory.Name
    $sampleUrl = $sampleJsonObj.url
    $created = $sampleJsonObj.creationDateTime
    $modified = $sampleJsonObj.updateDateTime
    $createdDt = ConvertToDateTime -DateTimeString $created
    $modifiedDt = ConvertToDateTime -DateTimeString $modified
       
    $sampleCount++
    
    $status = [PSCustomObject]@{
        Link = "[$($title)]($(ResolveLink $dirName))"
        Description = $sampleJsonObj.shortDescription
        Products = $($sampleJsonObj.products -join ', ')
        Categories = $($sampleJsonObj.categories -join ', ')
        Created = $created
        Modified = $modified
        CreatedDt = $createdDt
        ModifiedDt = $modifiedDt
        URL = $sampleUrl
    }

    $matrixRows += $status
}

# Output Report


$matrixRows | Sort-Object ModifiedDt -Descending | ForEach-Object{

    $row = "| {0} | {1} | {2} | " -f $_.Link, $_.CreatedDt.ToString("dd MMM yyyy"), $_.ModifiedDt.ToString("dd MMM yyyy")
    Write-Host $row

    $row | Out-File $reportFile -Append
}

$summary = "`nThere are **{0}** script scenarios in the site | Generated: {1} `n`n" -f $sampleCount, [System.DateTime]::Now.ToString("dd MMM yyyy hh:mm:ss")
Write-Host $summary
$summary | Out-File $reportFile -Append
