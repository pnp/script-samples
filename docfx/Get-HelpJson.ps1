

# PnP PowerShell
# powershell/documentation/*

function Process-PnPPowerShellDocs
{

    $pnppsDocs = Join-Path -Path $currentLocation -ChildPath "powershell/documentation"
    Write-Host "Processing PnP PowerShell Path: $($pnppsDocs)"
    $pnppsBaseSitePath = "https://pnp.github.io/powershell/cmdlets"
    $pnppsDocsFiles = Get-ChildItem -Path $pnppsDocs
    $pnppsDocRows = @()

    Write-Host "$($pnppsDocsFiles.Length) found"
    
    $pnppsDocsFiles | Foreach-Object {

        $fileTargetName = $_.Name.Replace(".md",".html")
        $cmdletName = $_.Name.Replace(".md","")

        $cmdHelp = [PSCustomObject]@{
            cmd = $cmdletName
            helpUrl = "$($pnppsBaseSitePath)/$($fileTargetName)"
        }

        $pnppsDocRows += $cmdHelp
    }


    $pnppsDocRows | ConvertTo-Json | Out-File "$($outputPath)\powershell.help.json"

    Write-Host "PnP PowerShell cmdlets documentation generated"
}


# SPO Management Shell
# office-docs-powershell\sharepoint\sharepoint-ps\sharepoint-online
function Process-SPOManagementShellDocs
{

    $spomsDocs = Join-Path -Path $currentLocation -ChildPath "office-docs-powershell\sharepoint\sharepoint-ps\sharepoint-online"
    Write-Host "Processing SPO Management Shell Path: $($spomsDocs)"
    $spomsBaseSitePath = "https://docs.microsoft.com/en-us/powershell/module/sharepoint-online"
    $spomsDocsFiles = Get-ChildItem -Path $spomsDocs
    $spomsDocRows = @()

    Write-Host "$($spomsDocsFiles.Length) found"
    
    $spomsDocsFiles | Foreach-Object {

        $cmdletName = $_.Name.Replace(".md","")

        $cmdHelp = [PSCustomObject]@{
            cmd = $cmdletName
            helpUrl = "$($spomsBaseSitePath)/$($cmdletName)?view=sharepoint-ps"
        }

        $spomsDocRows += $cmdHelp
    }


    $spomsDocRows | ConvertTo-Json | Out-File "$($outputPath)\spoms.help.json"

    Write-Host "SPO Management Shell cmdlets documentation generated"
}

# CLI for Microsoft 365
# 

# Pre Launch

# Update Repos - TODO

# For optimatization - only use help where cmdlet is used

# To refresh functions use . .\Get-HelpJson.ps1 in cmd window
$currentLocation = "C:\Git\utility\script-help\"
$outputPath = "$(Get-Location)\assets\help"
#Process-PnPPowerShellDocs
Process-SPOManagementShellDocs