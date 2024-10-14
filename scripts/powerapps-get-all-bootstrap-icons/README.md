---
plugin: add-to-gallery-preparation
---

# Get all Bootstrap Icons to use in your powerapps.

## Summary

This PowerShell script downloads the latest [Bootstrap icons](https://icons.getbootstrap.com/) from [twbs@github](https://github.com/twbs/icons/releases/latest), creates a JSON file with the complete list of SVG icons you can use.

# Use it in PowerApps
Copy the content from [BootstrapIcons.json](BootstrapIcons.json) and add it to **App.OnStart** (See also [Note about Named Formulas](#NoteaboutNamedFormulas)).
This will give you access to all the Bootstap Icons in your app.

To use an Icon, add an Image and the following code to the image property:
Change the <ICON NAME> for any name found in the [Bootstrap icons](https://icons.getbootstrap.com/) list, ex. alphabet-uppercase.


```
 data:image/svg+xml;utf8, " & EncodeUrl(" & LookUp(colBSIcons; IconName = <ICON NAME>).IconData)
```


# [PnP PowerShell](#tab/pnpps)

```powershell

# Define the URL for the latest Bootstrap Icons release
$latestReleaseUrl = "https://github.com/twbs/icons/releases/latest"

# Get latest Bootstrap Icons version
try {
    $latestReleaseResponse = Invoke-WebRequest -Uri $latestReleaseUrl -ErrorAction Stop
    $finalUrl = $latestReleaseResponse.BaseResponse.RequestMessage.RequestUri.AbsoluteUri
    $actualVersion = $finalUrl.Split('/')[-1]
} catch {
    Write-Host "An error occurred: $_"
}

#Download Bootstrap Icons zip file
try {
    $dlPath = "https://github.com/twbs/icons/releases/download/" + $actualVersion + "/"
    $dlName = "bootstrap-icons-" + $actualVersion.Substring(1) + ".zip"
    $dlFull = $dlPath + $dlName

    # Download the Bootstrap Icons zip file
    Write-Host "Downloading Bootstrap Icons version $actualVersion..."
    Invoke-WebRequest -Uri $dlFull -OutFile "bsicons.zip" -ErrorAction Stop
    Write-Host "Download completed."
}catch {
    Write-Error $_
}

# Prompt user for style choice
Write-Host "What language are you using?"
Write-Host "1. American/English"
Write-Host "2. Nordic countries"
$choice = Read-Host "Choose a number and press Enter"
while ($choice -ne 1 -and $choice -ne 2) {
    Write-Host "Choose 1 or 2 and press Enter"
    $choice = Read-Host "Choose a number and press Enter"
}

# Create the new Json file with all the icons
if ($choice -eq 1) {
    $newJson = "ClearCollect(`n`tcolBSIcons,`n"
} elseif ($choice -eq 2) {
    $newJson = "ClearCollect(`n`tcolBSIcons;`n"
}

Add-Type -AssemblyName "System.IO.Compression.FileSystem"
$zipFile = [System.IO.Compression.ZipFile]::OpenRead("$PSScriptRoot\bsicons.zip")

# Process the SVG files and add them to the JSON
foreach ($entry in $zipFile.Entries) {
    if ($entry.FullName.EndsWith(".svg")) {
        $filename = $entry.FullName.Substring(23, $entry.FullName.Length - 27)
        $iconData = [System.IO.StreamReader]::new($entry.Open()).ReadToEnd()
        $iconData = $iconData.Replace('"', "'").Replace("`n", "`n`t`t`t")
        
        if ($choice -eq 1) {
            $newJson += "`t`t{IconName: `"$filename`",`n`t`tIconData: `"$iconData`t`"},`n"
        } elseif ($choice -eq 2) {
            $newJson += "`t`t{IconName: `"$filename`";`n`t`tIconData: `"$iconData`t`"};`n"
        }
    }
}

# Finalize and save the JSON file
$newJson = $newJson.Substring(0, $newJson.Length - 2) + "`n)"
Set-Content -Path "BootstrapIcons.json" -Value $newJson

# Output the final message
if ($choice -eq 1) {
    Write-Host -ForegroundColor Green "You have now downloaded $actualVersion of Bootstrap Icons and it's saved in the BootstrapIcons.json."
    Write-Host "1. Open the file and copy the content to your power app in the OnStart field of the App."
    Write-Host "2. Use the following code in the image content:"
    Write-Host "`tdata:image/svg+xml;utf8, `" & EncodeUrl(`" & LookUp(colBSIcons, IconName = `<ICON NAME ex. grid-3x3-gap-fill>`).IconData)"
} elseif ($choice -eq 2) {
    Write-Host -ForegroundColor Green "You have now downloaded $actualVersion of Bootstrap Icons and it's saved in the BootstrapIcons.json."
    Write-Host "1. Open the file and copy the content to your power app in the OnStart field of the App."
    Write-Host "2. Use the following code in the image content:"
    Write-Host "`tdata:image/svg+xml;utf8, `" & EncodeUrl(`" & LookUp(colBSIcons; IconName = `<ICON NAME ex. grid-3x3-gap-fill>`).IconData)"
}

# Close the zip file and remove it
$zipFile.Dispose()
Remove-item -Path "$PSScriptRoot\bsicons.zip"

```

## Note about Named Formulas
A new feature in Power Apps allows for a better implementation, namely Named Formulas. At current this app is not designed for this function, but a future version is planned for handling all this in a better way.


## Source Credit

Sample first appeared on [https://github.com/dkaaven/MyPowerAppScript](https://github.com/dkaaven/MyPowerAppScript)

## Contributors

| Author(s) |
|-----------|
| [Daniel Kåven](https://github.com/dkaaven)|


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission" aria-hidden="true" />