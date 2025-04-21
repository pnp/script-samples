# Script for reporting the information from the samples

## Variables
param(
    [string]$BaseDir = "D:\contrib\pkb-script-samples\",
    [string]$ScriptFolder = "scripts",
    [string]$OutputFile = "samples.json",
    [string]$AssetsFolder = "assets"
)

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

$dir = Join-Path -Path $BaseDir -ChildPath $ScriptFolder
$files = Get-ChildItem -Path $dir -Recurse -Include README.md

Write-Host "$($files.Length) found"

$consolidatedSamplesFile = @()

$files | Foreach-Object {

    # Skip these
    if($_.Directory.Name -eq "scripts" -or
        $_.Directory.Name -eq "_template-script-submission"){
        return
    }

    $sampleJsonObj = GetJsonFromSampleJson -SamplePath $_.Directory -DefaultReturn $_.Directory.Name
    
    # Remove LongDescription and Description from the sampleJsonObj
    $sampleJsonObj.PSObject.Properties.Remove("LongDescription")
    $sampleJsonObj.PSObject.Properties.Remove("References")
    $sampleJsonObj.PSObject.Properties.Remove("Source")

    # Update Sample Url 
    $sampleJsonObj.Url = $sampleJsonObj.Url.Replace("https://pnp.github.io/script-samples/", "")

    if($sampleJsonObj.thumbnails.length -gt 0){
        $sampleJsonObj.thumbnails | ForEach-Object {
            $_.Url = $_.Url.Replace("https://raw.githubusercontent.com/pnp/script-samples/main/scripts/", "")
        }
    }

    $consolidatedSamplesFile += $sampleJsonObj
}

# Output Report
$consolidatedSamplesFile | ConvertTo-Json -Depth 10 | Out-File $OutputFile -Force