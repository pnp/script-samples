param (
    [string]$solutionPath = ".\UnpackedSolution",
    [string]$solutionZip = ".\SolutionZip\YourSolution.zip",
    [string]$solutionPackagerPath = ".\tools\SolutionPackager.exe",

    [string]$ModelDrivenAppNamePattern = '^[A-Za-z][A-Za-z0-9]*[-_][A-Za-z0-9 _-]+$',

    [string]$TableLogicalNamePattern = '^[a-z][a-z0-9]*_[A-Za-z0-9_]+$',

    [string]$FlowNamePattern = '^[A-Za-z][A-Za-z0-9]*[-_][A-Za-z0-9_-]+$',

    [string]$CanvasScreenNamePattern = '^[A-Za-z][A-Za-z0-9_]*$',

    [string]$ReportPath
)

$ErrorActionPreference = 'Stop'
$findings = [System.Collections.Generic.List[object]]::new()

function Add-Finding {
    param (
        [ValidateSet('Warning', 'Error')]
        [string]$Severity,
        [string]$Rule,
        [string]$Path,
        [string]$Message
    )

    $findings.Add([pscustomobject]@{
        Severity = $Severity
        Rule     = $Rule
        Path     = $Path
        Message  = $Message
    })
}

function Get-ComponentFiles {
    param (
        [string]$FolderName,
        [string]$Filter,
        [string]$Rule
    )

    $folderPath = Join-Path -Path $solutionPath -ChildPath $FolderName
    if (!(Test-Path -LiteralPath $folderPath -PathType Container)) {
        Add-Finding -Severity Warning -Rule $Rule -Path $folderPath -Message 'Optional component folder is not present.'
        return @()
    }

    try {
        return @(Get-ChildItem -LiteralPath $folderPath -Filter $Filter -File -Recurse -ErrorAction Stop)
    } catch {
        Add-Finding -Severity Error -Rule "$Rule.Read" -Path $folderPath -Message $_.Exception.Message
        return @()
    }
}

$patterns = @{
    ModelDrivenApp = $ModelDrivenAppNamePattern
    Table          = $TableLogicalNamePattern
    Flow           = $FlowNamePattern
    CanvasScreen   = $CanvasScreenNamePattern
}

foreach ($patternName in $patterns.Keys) {
    try {
        [void][regex]::new($patterns[$patternName])
    } catch {
        throw "Invalid regular expression for $patternName`: $($_.Exception.Message)"
    }
}

Write-Host 'Running Power Platform solution validation...'

# Unpack the solution if it has not already been extracted.
if (!(Test-Path -LiteralPath $solutionPath -PathType Container)) {
    Write-Host "Solution path '$solutionPath' does not exist. Attempting to unpack the solution..."

    if (!(Test-Path -LiteralPath $solutionZip -PathType Leaf)) {
        throw "Solution zip file '$solutionZip' was not found. Cannot unpack."
    }

    if (!(Test-Path -LiteralPath $solutionPackagerPath -PathType Leaf)) {
        throw "SolutionPackager.exe was not found at '$solutionPackagerPath'."
    }

    & $solutionPackagerPath /action:Extract "/zipfile:$solutionZip" "/folder:$solutionPath" /packagetype:Unmanaged
    if ($LASTEXITCODE -ne 0) {
        throw "SolutionPackager failed with exit code $LASTEXITCODE."
    }

    if (!(Test-Path -LiteralPath $solutionPath -PathType Container)) {
        throw "Unpacking failed. Solution path '$solutionPath' still does not exist."
    }

    Write-Host 'Solution unpacked successfully.'
}

# Validate Model-Driven Apps.
$modelApps = Get-ComponentFiles -FolderName 'ModelDrivenApps' -Filter '*.xml' -Rule 'ModelDrivenApp'
foreach ($app in $modelApps) {
    try {
        [xml]$xml = Get-Content -LiteralPath $app.FullName -Raw
        $appNode = $xml.SelectSingleNode("//*[local-name()='appmoduleid']")
        $displayName = if ($appNode) { $appNode.GetAttribute('displayname') }
        if ([string]::IsNullOrWhiteSpace($displayName)) {
            Add-Finding -Severity Error -Rule 'ModelDrivenApp.Name' -Path $app.FullName -Message 'Could not read the app display name from appmoduleid metadata.'
        } elseif ($displayName -notmatch $ModelDrivenAppNamePattern) {
            Add-Finding -Severity Error -Rule 'ModelDrivenApp.Name' -Path $app.FullName -Message "App name '$displayName' does not match '$ModelDrivenAppNamePattern'."
        }
    } catch {
        Add-Finding -Severity Error -Rule 'ModelDrivenApp.Parse' -Path $app.FullName -Message $_.Exception.Message
    }
}

# Validate Dataverse table logical names.
# SolutionPackager creates one folder under Entities for each Dataverse table.
# Validate that folder name rather than recursively inspecting every XML file.
$entitiesRoot = Join-Path -Path $solutionPath -ChildPath 'Entities'

if (!(Test-Path -LiteralPath $entitiesRoot -PathType Container)) {
    Add-Finding `
        -Severity Warning `
        -Rule 'Table' `
        -Path $entitiesRoot `
        -Message 'Optional Entities folder is not present.'
}
else {
    try {
        $tableFolders = @(
            Get-ChildItem `
                -LiteralPath $entitiesRoot `
                -Directory `
                -ErrorAction Stop
        )

        foreach ($tableFolder in $tableFolders) {
            $logicalName = $tableFolder.Name

            if ($logicalName -notmatch $TableLogicalNamePattern) {
                Add-Finding `
                    -Severity Error `
                    -Rule 'Table.LogicalName' `
                    -Path $tableFolder.FullName `
                    -Message "Table logical name '$logicalName' does not match '$TableLogicalNamePattern'."
            }
        }
    }
    catch {
        Add-Finding `
            -Severity Error `
            -Rule 'Table.Read' `
            -Path $entitiesRoot `
            -Message $_.Exception.Message
    }
}

# Validate cloud flow names.
$flows = Get-ComponentFiles `
    -FolderName 'Workflows' `
    -Filter '*.json' `
    -Rule 'Flow'

foreach ($flow in $flows) {
    try {
        $json = Get-Content `
            -LiteralPath $flow.FullName `
            -Raw |
            ConvertFrom-Json -ErrorAction Stop

        $name = $null

        # Prefer the display name from workflow metadata when available.
        if (
            $null -ne $json.properties -and
            -not [string]::IsNullOrWhiteSpace(
                [string]$json.properties.displayName
            )
        ) {
            $name = [string]$json.properties.displayName
        }
        else {
            # SolutionPackager workflow filenames commonly contain the
            # readable name followed by the workflow GUID.
            $fileNameWithoutExtension =
                [System.IO.Path]::GetFileNameWithoutExtension($flow.Name)

            $name = $fileNameWithoutExtension -replace `
                '-[0-9A-Fa-f]{8}(?:-[0-9A-Fa-f]{4}){3}-[0-9A-Fa-f]{12}$',
                ''
        }

        if ([string]::IsNullOrWhiteSpace($name)) {
            Add-Finding `
                -Severity Error `
                -Rule 'Flow.Name' `
                -Path $flow.FullName `
                -Message 'Could not determine the flow name from the workflow JSON or exported filename.'
        }
        elseif ($name -notmatch $FlowNamePattern) {
            Add-Finding `
                -Severity Error `
                -Rule 'Flow.Name' `
                -Path $flow.FullName `
                -Message "Flow name '$name' does not match '$FlowNamePattern'."
        }
    }
    catch {
        Add-Finding `
            -Severity Error `
            -Rule 'Flow.Parse' `
            -Path $flow.FullName `
            -Message $_.Exception.Message
    }
}

# Validate screen names only when supported canvas source files are available.
$canvasRoot = Join-Path -Path $solutionPath -ChildPath 'CanvasApps'
if (!(Test-Path -LiteralPath $canvasRoot -PathType Container)) {
    Add-Finding -Severity Warning -Rule 'CanvasApp' -Path $canvasRoot -Message 'Optional CanvasApps folder is not present.'
} else {
    $canvasTempRoot = $null
    try {
        $sourceDirectories = @(Get-ChildItem -LiteralPath $canvasRoot -Directory -Recurse -ErrorAction Stop | Where-Object Name -ieq 'Src')
        $sourceRoots = [System.Collections.Generic.List[string]]::new()
        foreach ($sourceDirectory in $sourceDirectories) {
            $sourceFiles = @(Get-ChildItem -LiteralPath $sourceDirectory.FullName -File -ErrorAction Stop | Where-Object Name -like '*.pa.yaml')
            if ($sourceFiles.Count -gt 0) {
                $sourceRoots.Add($sourceDirectory.FullName)
            }
        }

        if ($sourceRoots.Count -eq 0) {
            $msappFiles = @(Get-ChildItem -LiteralPath $canvasRoot -Filter '*.msapp' -File -Recurse -ErrorAction Stop)
            if ($msappFiles.Count -gt 0) {
                $canvasTempRoot = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([guid]::NewGuid().ToString())
                New-Item -ItemType Directory -Path $canvasTempRoot -Force | Out-Null

                foreach ($msappFile in $msappFiles) {
                    $appTempRoot = Join-Path -Path $canvasTempRoot -ChildPath ([guid]::NewGuid().ToString())
                    New-Item -ItemType Directory -Path $appTempRoot -Force | Out-Null
                    $archivePath = Join-Path -Path $appTempRoot -ChildPath 'canvas-app.zip'
                    $extractPath = Join-Path -Path $appTempRoot -ChildPath 'source'
                    Copy-Item -LiteralPath $msappFile.FullName -Destination $archivePath -ErrorAction Stop
                    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractPath -Force -ErrorAction Stop
                    $appSourceDirectories = @(Get-ChildItem -LiteralPath $extractPath -Directory -Recurse -ErrorAction Stop | Where-Object Name -ieq 'Src')
                    $extractedSourceFileCount = 0
                    foreach ($appSourceDirectory in $appSourceDirectories) {
                        $appSourceFiles = @(Get-ChildItem -LiteralPath $appSourceDirectory.FullName -File -ErrorAction Stop | Where-Object Name -like '*.pa.yaml')
                        if ($appSourceFiles.Count -gt 0) {
                            $sourceRoots.Add($appSourceDirectory.FullName)
                            $extractedSourceFileCount += $appSourceFiles.Count
                        }
                    }

                    if ($extractedSourceFileCount -eq 0) {
                        Add-Finding -Severity Warning -Rule 'CanvasApp.Source' -Path $msappFile.FullName -Message 'No supported *.pa.yaml source files were found in this app package; screen naming validation was skipped.'
                    }
                }
            }
        }

        if ($sourceRoots.Count -eq 0 -and $msappFiles.Count -eq 0) {
            Add-Finding -Severity Warning -Rule 'CanvasApp.Source' -Path $canvasRoot -Message 'No supported *.pa.yaml source files or .msapp packages were found; screen naming validation was skipped.'
        }

        foreach ($sourceRoot in $sourceRoots) {
            $sourceFiles = @(Get-ChildItem -LiteralPath $sourceRoot -File -ErrorAction Stop | Where-Object Name -like '*.pa.yaml')
            $appSource = $sourceFiles | Where-Object Name -ieq 'App.pa.yaml' | Select-Object -First 1
            if (!$appSource) {
                Add-Finding -Severity Error -Rule 'CanvasApp.AppSource' -Path $sourceRoot -Message 'Canvas source folder contains screen files but is missing App.pa.yaml.'
            }

            $screenFiles = @(
                    $sourceFiles |
                        Where-Object {
                            $_.Name -notlike 'App.pa.yaml' -and
                            $_.Name -notlike '_*.pa.yaml'
                        }
                )
                foreach ($screen in $screenFiles) {
                    $screenName = $screen.Name -replace '\.pa\.yaml$', ''
                    if ($screenName -notmatch $CanvasScreenNamePattern) {
                        Add-Finding -Severity Error -Rule 'CanvasApp.ScreenName' -Path $screen.FullName -Message "Canvas screen name '$screenName' does not match '$CanvasScreenNamePattern'."
                    }
                }
            }
    } catch {
        Add-Finding -Severity Error -Rule 'CanvasApp.Read' -Path $canvasRoot -Message $_.Exception.Message
    } finally {
        if ($canvasTempRoot -and (Test-Path -LiteralPath $canvasTempRoot)) {
            Remove-Item -LiteralPath $canvasTempRoot -Recurse -Force
        }
    }
}

foreach ($finding in $findings) {
    $color = if ($finding.Severity -eq 'Error') { 'Red' } else { 'Yellow' }
    Write-Host "[$($finding.Severity)] $($finding.Rule): $($finding.Path) - $($finding.Message)" -ForegroundColor $color
}

if ($ReportPath) {
    $reportDirectory = Split-Path -Parent $ReportPath
    if ($reportDirectory -and !(Test-Path -LiteralPath $reportDirectory -PathType Container)) {
        New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
    }
    ConvertTo-Json -InputObject @($findings) -Depth 5 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
    Write-Host "Validation report written to '$ReportPath'."
}

$errorCount = @($findings | Where-Object Severity -eq 'Error').Count
$warningCount = @($findings | Where-Object Severity -eq 'Warning').Count
Write-Host "Validation complete: $errorCount error(s), $warningCount warning(s)."

if ($errorCount -gt 0) {
    exit 1
}

Write-Host 'All configured validations passed.'
exit 0