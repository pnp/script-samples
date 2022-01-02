# Script for reporting the information from the samples

## Variables
param(
    [string]$BaseDir = "C:\Git\contrib\script-samples\",
    [string]$ScriptFolder = "scripts",
    [string]$ReportFile = "metadata-report.md",
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

function DispNope{
    [CmdletBinding()]
    param (
        [Parameter()]
        [bool]
        $in
    )

    if($in -eq $true){
        return "`u{1F937}"
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

# Check all pages for tabs and three ***

$dir = Join-Path -Path $BaseDir -ChildPath $ScriptFolder

$files = Get-ChildItem -Path $dir -Recurse -Include README.md

Write-Host "$($files.Length) found"

"# Metadata Report of Samples"  | Out-File $ReportFile -Force
"| Sample | Description (Short) | Products | Categories | Tags | Metadata | Image URL |" | Out-File $reportFile -Append
"|------|--------|:--------:|:--------:|:----------:|:-----------:|:--------:|"  | Out-File $reportFile -Append

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
    $imgUrl = $sampleJsonObj.thumbnails[0].Url
    $imgStatus = DispNope -in $true

    if($imgUrl -like "https://raw.githubusercontent.com/pnp/script-samples/main/scripts/*"){
        $imgStatus = DispTick -in $true
    }


    $sampleCount++
    
    $status = [PSCustomObject]@{
        Link = "[$($title)]($(ResolveLink $dirName))"
        Description = $sampleJsonObj.shortDescription
        Products = $($sampleJsonObj.products -join ',')
        Categories = $($sampleJsonObj.categories -join ', ')
        Tags = $($sampleJsonObj.tags -join ', ')
        Metadata = $($sampleJsonObj.metadata.key -join ', ')
        ImageUrl = $sampleJsonObj.thumbnails[0].Url
    }

    $matrixRows += $status
}

# Output Report


$matrixRows | ForEach-Object{

    $row = "| {0} | {1} | {2} | {3} | {4} | {5} | {6} |" -f $_.Link, $_.Description, $_.Products, $_.Categories, $_.Tags, $_.Metadata, $imgStatus
    Write-Host $row

    $row | Out-File $reportFile -Append
}

