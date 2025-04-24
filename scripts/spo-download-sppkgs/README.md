

# Download sppkgs from App Catalog

## Summary

Download all packages from the App Catalog.

# [PnP PowerShell](#tab/pnpps)

```powershell

param (
  [Parameter(Mandatory = $true)]
  [string]$url,
  [Parameter(Mandatory = $true)]
  [string]$appCatalog,
  [Parameter(Mandatory = $true)]
  [string]$username,
  [Parameter(Mandatory = $true)]
  [string]$password
)

Clear-Host
Write-Progress -activity "Downloading packages..." -status "downloading" -PercentComplete 0

# Connect
$psw = ConvertTo-SecureString -String $password -AsPlainText -Force
$credentials = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username, $psw
Connect-PnPOnline -Url $url -Credentials $credentials

Try {
  $list = Get-PnPList -Identity $appCatalog
  $folder = Get-PnPFolder -RelativeUrl $appCatalog
  $props = Get-PnPProperty -ClientObject $folder -Property Files
  $destinationfolder = ".\pkg"

  if (!(Test-Path -path $destinationfolder)) {
    $newItem = New-Item $destinationfolder -type directory
  }

  $item = Get-ChildItem -Path $destinationfolder -Include *.* -File -Recurse | ForEach-Object { $_.Delete() }
  $total = $folder.Files.Count

  For ($i = 0; $i -lt $total; $i++) {
    $file = $folder.Files[$i]
    $fileName = $file.Name
    $extn = [IO.Path]::GetExtension($file.Name)

    if ($extn -eq ".sppkg" ) {
      Write-Progress -activity "Downloading packages..." -status "downloading $fileName" -PercentComplete (($i / $total) * 100)
      $f = Get-PnPFile -ServerRelativeUrl $file.ServerRelativeUrl -Path $destinationfolder -FileName $file.Name -AsFile
    }
  }
}
Catch {
  Write-host -f Red "Error downloading packages:" $_.Exception.Message
}

Write-Host ("PACKAGES DOWNLOADED") -ForegroundColor Green
Disconnect-PnPOnline

```

[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]

---

## Contributors

| Author(s)                                 |
| ----------------------------------------- |
| [Matteo Serpi](https://github.com/srpmtt) |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/spo-download-sppkgs" aria-hidden="true" />
