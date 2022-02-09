# Script for reporting the information from the samples

## Variables
param(
    [string]$BaseDir = "C:\Git\contrib\script-samples\",
    [string]$ScriptFolder = "scripts",
    [string]$ReportFile = "metadata.md",
    [string]$AssetsFolder = "assets"
)

function DispTick{
    return "`u{1F44D}"
}

function DispNope{
    return "`u{1F937}"
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
"| Sample | Products | Categories | Tags | Metadata | URL | Image URL | Source Credit | Reference Count |" | Out-File $reportFile -Append
"|--------|:--------:|:----------:|:----:|:--------:|:---------:|:---------:|:-------------:|:---------------:|"  | Out-File $reportFile -Append

$matrixRows = @()
$sampleCount = 0

$files | Foreach-Object {

    # Skip these
    if($_.Directory.Name -eq "scripts" -or
        $_.Directory.Name -eq "_template-script-submission"){
        return
    }

    $sampleJsonObj = GetJsonFromSampleJson -SamplePath $_.Directory -DefaultReturn $_.Directory.Name

    $content = Get-Content -Path $_.FullName -Raw
    $title = $sampleJsonObj.title
    $dirName = $_.Directory.Name
    $imgUrl = $sampleJsonObj.thumbnails[0].url
    $sampleUrl = $sampleJsonObj.url
    $imgStatus = ""
    $sampleUrlStatus = ""
    $sourceCreditReference = "-"
    $referenceCount = 0 
    $tags = ""

    if($imgUrl -like "https://raw.githubusercontent.com/pnp/script-samples/main/scripts/*"){
        $imgStatus = DispTick
    }else{
        $imgStatus = DispNope
    }

    if($sampleUrl -like "https://pnp.github.io/script-samples/*"){
        $sampleUrlStatus = DispTick
    }else{
        $sampleUrlStatus = DispNope
    }

    if($content.Contains("#tab/cli-m365-ps")){
        $sourceCreditReference = DispTick
    }

    if($sampleJsonObj.PSobject.Properties.name -match "references"){
        if($sampleJsonObj.references){
            $referenceCount = $sampleJsonObj.references.length
        }
    }

    if($sampleJsonObj.PSobject.Properties.name -match "tags"){
        if($sampleJsonObj.tags){
            $tags = $sampleJsonObj.tags -join ', '
        }
    }
    
    $sampleCount++
    
    $status = [PSCustomObject]@{
        Link = "[$($title)]($(ResolveLink $dirName))"
        Description = $sampleJsonObj.shortDescription
        Products = $($sampleJsonObj.products -join ', ')
        Categories = $($sampleJsonObj.categories -join ', ')
        Tags = $tags
        Metadata = $($sampleJsonObj.metadata.key -join ', ')
        URL = $sampleUrlStatus
        ImageStatus = $imgStatus
        HasSourceCredit = $sourceCreditReference
        ReferenceCount = $referenceCount
    }

    $matrixRows += $status
}

# Output Report


$matrixRows | ForEach-Object{

    $row = "| {0} | {1} | {2} | {3} | {4} | {5} | {6} | {7} | {8} |" -f $_.Link, $_.Products, $_.Categories, $_.Tags, $_.Metadata, $_.URL, $_.ImageStatus, $_.HasSourceCredit, $_.ReferenceCount
    Write-Host $row

    $row | Out-File $reportFile -Append
}

$summary = "`nThere are **{0}** script scenarios with metadata in the site | Generated: {1} `n`n" -f $sampleCount, [System.DateTime]::Now.ToString("dd MMM yyyy hh:mm:ss")
Write-Host $summary
$summary | Out-File $reportFile -Append