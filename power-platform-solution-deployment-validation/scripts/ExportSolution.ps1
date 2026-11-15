param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$EnvironmentUrl,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$SolutionName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ExportPath
)

$ErrorActionPreference = "Stop"
$pacCommand = Get-Command pac -CommandType Application -ErrorAction Stop | Select-Object -First 1

function Invoke-Pac {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$Operation
    )

    & $pacCommand.Source @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "PAC $Operation failed with exit code $LASTEXITCODE."
    }
}

$resolvedExportPath = [System.IO.Path]::GetFullPath($ExportPath)
$exportDirectory = Split-Path -Parent $resolvedExportPath

if (!(Test-Path -LiteralPath $exportDirectory)) {
    New-Item -ItemType Directory -Path $exportDirectory -Force | Out-Null
}

Write-Host "Using Power Platform CLI at '$($pacCommand.Source)'."
Write-Host "Exporting '$SolutionName' from '$EnvironmentUrl'..."

Invoke-Pac -Arguments @(
    "solution",
    "export",
    "--name",
    $SolutionName,
    "--path",
    $resolvedExportPath,
    "--managed",
    "false",
    "--overwrite"
) -Operation "solution export"

Write-Host "Export completed successfully."