$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

# Data Generated Content
$runLocation  = Get-Location
#.\report-matrix.ps1 -BaseDir "$($runLocation)\..\"  -ReportFile "matrix.md"
#.\report-metadata.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "metadata.md"
#.\report-cmdusage.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "usage.md"
#.\report-age.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "age.md"

Write-Host "Generating samples.json..." -ForegroundColor Cyan
.\generate-samplesJson.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "samples.json"

# Main DocFX build
Write-Host "Building docfx..." -ForegroundColor Cyan
docfx build docfx.json --warningsAsErrors $args
