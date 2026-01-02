$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

# Data Generated Content
$runLocation  = Get-Location
#.\report-matrix.ps1 -BaseDir "$($runLocation)\..\"  -ReportFile "matrix.md"
#.\report-metadata.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "metadata.md"
#.\report-cmdusage.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "usage.md"
#.\report-age.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "age.md"

Write-Host "Generating samples.json..." -ForegroundColor Cyan
$baseDir = (Resolve-Path (Join-Path $runLocation "..")).Path
./generate-samplesJson.ps1 -BaseDir $baseDir -ReportFile "samples.json"

# Main DocFX build
Write-Host "Building docfx..." -ForegroundColor Cyan

<#
    DocFx is now installed as a .NET tool. To use it:
    
    1. Ensure .NET SDK is installed (version 6.0 or higher)
       - Download from: https://dotnet.microsoft.com/download
    
    2. Restore the docfx tool (if not already done):
       - Run: dotnet tool restore
    
    3. Run docfx using:
       - dotnet docfx build docfx.json
#>

Write-Host "Running docfx using .NET tool..." -ForegroundColor Cyan
dotnet docfx build docfx.json --warningsAsErrors $args
