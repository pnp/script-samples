<# 
----------------------------------------------------------------------------

    Title: Generate new Script Sample
    Website: https://pnp.github.io/script-samples/

    References:

        https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters
        https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_functions_argument_completion 
 
    Examples:

        .\New-Sample.ps1 -ScriptFolderName a-test-folder -ScriptTitle "Test Script" -ScriptTool PnPPowerShell `
            -ScriptShortDescription "This is a test script for checking the script" `
            -AuthorFullName "Paul Bullock" -GitHubId "pkbullock"

        .\New-Sample.ps1 -ScriptFolderName a-test-folder -ScriptTitle "Test Script" `
            -ScriptShortDescription "This is a test script for checking the script" `
            -ScriptTool PnPPowerShell,CliForMicrosoft365,SPOManagementShell  `
            -AuthorFullName "Paul Bullock" -GitHubId "pkbullock"

    To remove the generated sample:

        remove-item scripts/a-test-folder -Recurse -Force

----------------------------------------------------------------------------
#>

[CmdletBinding()]
param (

    #[ValidatePattern("")]
    [Parameter(Mandatory,
        HelpMessage = "The folder name for the script e.g. spo-get-list-items or graph-export-teams")]
    [Alias("FolderName")]
    [string] $ScriptFolderName,

    [Parameter(Mandatory,
        HelpMessage = "The title for the script e.g. Generate a list of SharePoint Sites")]
    [Alias("Title")]
    [string] $ScriptTitle,

    [Parameter(Mandatory,
        HelpMessage = "The description for the script")]
    [Alias("Description")]
    [string] $ScriptShortDescription,

    [ValidateSet('PnPPowerShell', 'CliForMicrosoft365', 'SPOManagementShell', 'CliForMicrosoft365Bash', `
             'MicrosoftGraphPowerShell', 'AzureCli', 'PowerAppsPowerShell', 'MicrosoftTeamsPowerShell', 'All')]
    [Parameter(Mandatory,
        HelpMessage = "The tool used to run the script e.g. PnP-PowerShell, Cli-For-Microsoft-365, SPO-Management-Shell")]
    [Alias("Tool")]
    [string[]] $ScriptTool,

    [Parameter(Mandatory,
        HelpMessage = "The name of the script author e.g. Paul Bullock")]
    [Alias("MyName", "Author")]
    [string] $AuthorFullName,

    [Parameter(Mandatory,
        HelpMessage = "Your GitHub ID, e.g. pkbullock, this is only for attribution on the sample")]
    [Alias("GHID", "AuthorId")]
    [string] $GitHubId,

    [switch]$KeepSourceCredit

)
begin{

    # ------------------------------------------------------------------------------
    # Global Variables
    # ------------------------------------------------------------------------------
    $mainScriptFolder = "scripts"
    $sampleTemplateFolder = "_template-script-submission"
    $sampleAssetsFolder = "assets"
    $jsonSample = "sample.json"
    $jsonSampleTemplate = "template.sample.json"
    $readmeFile = "README.md"

    # ------------------------------------------------------------------------------
    # README Variables
    # ------------------------------------------------------------------------------

    $pluginDefaultName = "plugin: add-to-gallery-preparation"
    $pluginActiveName = "plugin: add-to-gallery"
    $readmeDefaultTitle = "<title>"
    $readmeDefaultTelemetryLink = "https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission"
    $readmeDefaultAuthorName = "<-you->"

    $readmeSourceCreditTitle = "## Source Credit"
    $readmeSourceCreditText = "Sample first appeared on [https://pnp.github.io/cli-microsoft365/sample-scripts/spo/add-app-catalog/](https://pnp.github.io/cli-microsoft365/sample-scripts/spo/add-app-catalog/)"

    $scriptBlockEnding = "***"
    $psScriptPlaceholderReplaceHeader = "`powershell"
    $psScriptBashPlaceholderReplaceHeader = "``````bash"
    $psScriptPlaceholderReplaceFooter = "``"
    $psScriptPlaceholderReplaceBody = "<your script>"

    $psScriptBlock = @"
```````powershell

<your script>  

```````
"@

    $bashScriptBlock = @"
```````bash

<your script>  

```````
"@

    # Todo: Example on all the tool tab types
    $tabBlocks = @{
        "PnPPowerShell" = [PSCustomObject]@{
            Tab = "# [PnP PowerShell](#tab/pnpps)"
            IncludeBlock = "[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]"
            ScriptBlock  = $psScriptBlock
            Reference = [PSCustomObject]@{
                "name" = "Want to learn more about PnP PowerShell and the cmdlets"
                "description" = "Check out the PnP PowerShell site to get started and for the reference to the cmdlets."
                "url" = "https://aka.ms/pnp/powershell"
            }
            Metadata = [PSCustomObject]@{
            }
        }
        
        "CliForMicrosoft365" = [PSCustomObject]@{
            Tab = "# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)"
            IncludeBlock = "[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]"
            ScriptBlock  = $psScriptBlock
            Reference = [PSCustomObject]@{
                "name" = "Want to learn more about CLI for Microsoft 365 and the commands"
                "description" = "Check out the CLI for Microsoft 365 site to get started and for the reference to the commands."
                "url" = "https://aka.ms/cli-m365"
            }
            Metadata = [PSCustomObject]@{
            }
        }
        "SPOManagementShell"  = [PSCustomObject]@{
            Tab = "# [SPO Management Shell](#tab/spoms-ps)"
            IncludeBlock = "[!INCLUDE [More about SPO Management Shell](../../docfx/includes/MORE-SPOMS.md)]"
            ScriptBlock  = $psScriptBlock
            Reference = [PSCustomObject]@{
                "name" = "Introduction to the SharePoint Online Management Shell"
                "description" = "Check out the SPO Management Shell documentation site to get started and for the reference to the cmdlets."
                "url" = "https://learn.microsoft.com/powershell/sharepoint/sharepoint-online/introduction-sharepoint-online-management-shell"
            }
            Metadata = [PSCustomObject]@{
            }
        }

        "CliForMicrosoft365Bash"  = [PSCustomObject]@{
            Tab = "# [CLI for Microsoft 365 using Bash](#tab/cli-m365-bash)"
            IncludeBlock = "[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]"
            ScriptBlock  = $psScriptBlock
            Reference = [PSCustomObject]@{
                "name" = "Want to learn more about CLI for Microsoft 365 and the commands"
                "description" = "Check out the CLI for Microsoft 365 site to get started and for the reference to the commands."
                "url" = "https://aka.ms/cli-m365"  
            }
            Metadata = [PSCustomObject]@{
            }
        }

        "MicrosoftGraphPowerShell"  = [PSCustomObject]@{
            Tab = "# [Microsoft Graph PowerShell](#tab/graphps)"
            IncludeBlock = "[!INCLUDE [More about Microsoft Graph PowerShell SDK](../../docfx/includes/MORE-GRAPHSDK.md)]"
            ScriptBlock  = $psScriptBlock
            Reference = [PSCustomObject]@{
                "name" = "Want to learn more about Microsoft Graph PowerShell SDK and the cmdlets"
                "description" = "Check out the Microsoft Graph PowerShell SDK documentation site to get started and for the reference to the cmdlets."
                "url" = "https://learn.microsoft.com/graph/powershell/get-started"
            }
            Metadata = [PSCustomObject]@{
            }
        }

        "AzureCli"  = [PSCustomObject]@{
            Tab = "# [Azure CLI](#tab/azure-cli)"
            IncludeBlock = "[!INCLUDE [More about Azure CLI](../../docfx/includes/MORE-AZURECLI.md)]"
            ScriptBlock  = $psScriptBlock
            Reference = [PSCustomObject]@{
                "name" = "Want to learn more about Azure CLI and the commands"
                "description" = "Check out the Azure CLI documentation site to get started and for the reference to the commands."
                "url" = "https://learn.microsoft.com/cli/azure/"
            }
            Metadata = [PSCustomObject]@{
            }
        }

        "PowerAppsPowerShell" = [PSCustomObject]@{
            Tab = "# [Power Apps PowerShell](#tab/powerapps-ps)"
            IncludeBlock = "[!INCLUDE [More about Power Apps PowerShell](../../docfx/includes/MORE-POWERAPPS.md)]"
            ScriptBlock  = $psScriptBlock
            Reference = [PSCustomObject]@{
                "name" = "Want to learn more about Power Apps PowerShell and the cmdlets"
                "description" = "Check out the Power Apps PowerShell documentation site to get started and for the reference to the cmdlets."
                "url" = "https://learn.microsoft.com/power-platform/admin/powerapps-powershell"
            }
            Metadata = [PSCustomObject]@{
            }
        }

        "MicrosoftTeamsPowerShell" = [PSCustomObject]@{
            Tab = "# [MicrosoftTeams PowerShell](#tab/teamsps)"
            IncludeBlock = "[!INCLUDE [More about Microsoft Teams PowerShell](../../docfx/includes/MORE-TEAMSPS.md)]"
            ScriptBlock  = $psScriptBlock
            Reference = [PSCustomObject]@{
                "name" = "Want to learn more about Microsoft Teams PowerShell and the cmdlets"
                "description" = "Check out the Microsoft Teams PowerShell documentation site to get started and for the reference to the cmdlets."
                "url" = "https://learn.microsoft.com/microsoftteams/teams-powershell-overview"
            }
            Metadata = [PSCustomObject]@{
            }
        }
    }



    # ------------------------------------------------------------------------------
    # Introduction
    # ------------------------------------------------------------------------------

    Write-Host @"
    
 _____      _____      _____           _       _      _____                       _           
|  __ \     |  __ \   / ____|         (_)     | |    / ____|                     | |          
| |__) | __ | |__) | | (___   ___ _ __ _ _ __ | |_  | (___   __ _ _ __ ___  _ __ | | ___  ___ 
|  ___/ '_ \|  ___/   \___ \ / __| '__| | '_ \| __|  \___ \ / _` | '_ ` _ \| '_ \| |/ _ \/ __|
| |   | | | | |       ____) | (__| |  | | |_) | |_   ____) | (_| | | | | | | |_) | |  __/\__ \
|_|   |_| |_|_|      |_____/ \___|_|  |_| .__/ \__| |_____/ \__,_|_| |_| |_| .__/|_|\___||___/
                                        | |                                | |                
                                        |_|                                |_|                                                                                                                             
"@

    Write-Host " Welcome to PnP Script Samples, this script will generate a new script sample" -ForegroundColor Green
    
    # ------------------------------------------------------------------------------
    
}
process {
    
    # Request from user if they want to create a new script or update an existing one
    # $scriptAction = Read-Host "Do you want to create a new script or update an existing one? (new/update)"

    # ------------------------------------------------------------------------------
    # Create the sample files
    # ------------------------------------------------------------------------------

    # Copy the template to the script folder under the new name
    $templateSrc = Join-Path $mainScriptFolder -ChildPath $sampleTemplateFolder
    $targetFolder = Join-Path $mainScriptFolder -ChildPath $ScriptFolderName

    # Nesting Problem, need to test and create teh directory first then copy the contents

    if($PSVersionTable.PSVersion.Major -eq 5){
        Get-ChildItem -Path $templateSrc | Copy-Item -Destination $targetFolder -Force
        $srcAssetsFolder = Join-Path $templateSrc -ChildPath $sampleAssetsFolder
        Copy-Item -Path $srcAssetsFolder -Destination $targetFolder -Force -Recurse
    }else{
        Copy-Item -Path $templateSrc -Destination $targetFolder -Recurse -Force
    }
    
    Write-Host " Copied sample template to $targetFolder" -ForegroundColor Green

    # Rename the template.sample.json file to sample.json
    $scriptTemplateaBasePath = Join-Path $targetFolder -ChildPath $sampleAssetsFolder
    $scriptJsonTemplate = Join-Path $scriptTemplateaBasePath -ChildPath $jsonSampleTemplate
    Rename-Item $scriptJsonTemplate -NewName $jsonSample

    # ------------------------------------------------------------------------------
    # Update the README file
    # ------------------------------------------------------------------------------

    # Update the readme.md with the new information such as Title, FolderName, Tool
    $readmeFilePath = Join-Path $targetFolder -ChildPath $readmeFile
    $readmeContent = Get-Content $readmeFilePath -Raw
    $ScriptTelemetryLink = "https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/$ScriptFolderName"

    # Title
    $readmeContent = $readmeContent.Replace($readmeDefaultTitle, $ScriptTitle)
    # Plugin
    $readmeContent = $readmeContent.Replace($pluginDefaultName, $pluginActiveName)
    # Author
    $readmeContent = $readmeContent.Replace($readmeDefaultAuthorName, $AuthorFullName)
    # Telemetry
    $readmeContent = $readmeContent.Replace($readmeDefaultTelemetryLink, $ScriptTelemetryLink)
    # Source Credit
    if(!$KeepSourceCredit){
        $readmeContent = $readmeContent.Replace($readmeSourceCreditTitle, "")
        $readmeContent = $readmeContent.Replace($readmeSourceCreditText, "")
        $replaceNewLinesRN = "{0}{1}{2}{3}" -f "`r`n", "`r`n", "`r`n", "`r`n" 
        $readmeContent = $readmeContent.Replace($replaceNewLinesRN, "`n")
        $replaceNewLinesRNLv2 = "{0}{1}{2}" -f "`r`n", "`r`n", "`r`n"
        $readmeContent = $readmeContent.Replace($replaceNewLinesRNLv2, "`r`n`r`n")
    }

    # Tool Script Blocks
    $readmeContent = $readmeContent.Replace($psScriptPlaceholderReplaceHeader, "")
    $readmeContent = $readmeContent.Replace($psScriptBashPlaceholderReplaceHeader, "")
    $readmeContent = $readmeContent.Replace($psScriptPlaceholderReplaceFooter, "")
    $readmeContent = $readmeContent.Replace($psScriptPlaceholderReplaceBody, "")

    # Remove all tabs
    $readmeContent = $readmeContent.Replace($tabBlocks.PnPPowerShell.Tab, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.CliForMicrosoft365.Tab, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.CliForMicrosoft365Bash.Tab, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.SPOManagementShell.Tab, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.AzureCli.Tab, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.MicrosoftGraphPowerShell.Tab, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.MicrosoftTeamsPowerShell.Tab, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.PowerAppsPowerShell.Tab, "")
    
    # Remove all tab includes
    $readmeContent = $readmeContent.Replace($tabBlocks.PnPPowerShell.IncludeBlock, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.CliForMicrosoft365.IncludeBlock, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.SPOManagementShell.IncludeBlock, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.AzureCli.IncludeBlock, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.MicrosoftGraphPowerShell.IncludeBlock, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.MicrosoftTeamsPowerShell.IncludeBlock, "")
    $readmeContent = $readmeContent.Replace($tabBlocks.PowerAppsPowerShell.IncludeBlock, "")
    
    # Clean up the new lines
    $replaceNewLinesRN = "{0}{1}{2}{3}{4}{5}" -f "`r`n", "`r`n", "`r`n", "`r`n","`r`n","`r`n" 
    $readmeContent = $readmeContent.Replace($replaceNewLinesRN, "")
    
    switch ($ScriptTool) {
        "PnPPowerShell" { 

            $newBlock = "`n{0}`n`n{1}`n{2}`n{3}" -f $tabBlocks.PnPPowerShell.Tab, `
                                    $tabBlocks.PnPPowerShell.ScriptBlock, `
                                    $tabBlocks.PnPPowerShell.IncludeBlock, `
                                    $scriptBlockEnding

            $readmeContent = $readmeContent.Replace($scriptBlockEnding, $newBlock)

         }
        "CliForMicrosoft365" { 

            $newBlock = "`n{0}`n`n{1}`n{2}`n{3}" -f $tabBlocks.CliForMicrosoft365.Tab, `
                                    $tabBlocks.CliForMicrosoft365.ScriptBlock, `
                                    $tabBlocks.CliForMicrosoft365.IncludeBlock, `
                                    $scriptBlockEnding

            $readmeContent = $readmeContent.Replace($scriptBlockEnding, $newBlock)
         }
        "CliForMicrosoft365Bash" {

            $newBlock = "`n{0}`n`n{1}`n{2}`n{3}" -f $tabBlocks.CliForMicrosoft365Bash.Tab, `
                                    $tabBlocks.CliForMicrosoft365Bash.ScriptBlock, `
                                    $tabBlocks.CliForMicrosoft365Bash.IncludeBlock, `
                                    $scriptBlockEnding

            $readmeContent = $readmeContent.Replace($scriptBlockEnding, $newBlock)
          }
        "SPOManagementShell" {

            $newBlock = "`n{0}`n`n{1}`n{2}`n{3}" -f $tabBlocks.SPOManagementShell.Tab, `
                                    $tabBlocks.SPOManagementShell.ScriptBlock, `
                                    $tabBlocks.SPOManagementShell.IncludeBlock, `
                                    $scriptBlockEnding

            $readmeContent = $readmeContent.Replace($scriptBlockEnding, $newBlock)

          }
        "MicrosoftGraphPowerShell" { 

            $newBlock = "`n{0}`n`n{1}`n{2}`n{3}" -f $tabBlocks.MicrosoftGraphPowerShell.Tab, `
                                    $tabBlocks.MicrosoftGraphPowerShell.ScriptBlock, `
                                    $tabBlocks.MicrosoftGraphPowerShell.IncludeBlock, `
                                    $scriptBlockEnding

            $readmeContent = $readmeContent.Replace($scriptBlockEnding, $newBlock)

         }
        "AzureCli" { 

            $newBlock = "`n{0}`n`n{1}`n{2}`n{3}" -f $tabBlocks.AzureCli.Tab, `
            $tabBlocks.AzureCli.ScriptBlock, `
            $tabBlocks.AzureCli.IncludeBlock, `
            $scriptBlockEnding

            $readmeContent = $readmeContent.Replace($scriptBlockEnding, $newBlock)

         }
        "PowerAppsPowerShell" { 

            $newBlock = "`n{0}`n`n{1}`n{2}`n{3}" -f $tabBlocks.PowerAppsPowerShell.Tab, `
            $tabBlocks.PowerAppsPowerShell.ScriptBlock, `
            $tabBlocks.PowerAppsPowerShell.IncludeBlock, `
            $scriptBlockEnding

            $readmeContent = $readmeContent.Replace($scriptBlockEnding, $newBlock)

         }
        "MicrosoftTeamsPowerShell" { 

            $newBlock = "`n{0}`n`n{1}`n{2}`n{3}" -f $tabBlocks.MicrosoftTeamsPowerShell.Tab, `
                                    $tabBlocks.MicrosoftTeamsPowerShell.ScriptBlock, `
                                    $tabBlocks.MicrosoftTeamsPowerShell.IncludeBlock, `
                                    $scriptBlockEnding

            $readmeContent = $readmeContent.Replace($scriptBlockEnding, $newBlock)

          }
        Default {}
    }

    # Save README.md File
    $readmeContent | Out-File $readmeFilePath

    Write-Host " - Populated the README file in $targetFolder"

    # ------------------------------------------------------------------------------
    # Update the sample.json file
    # ------------------------------------------------------------------------------


    # Update the sample.json file with the new information such as Title, FolderName, Tool, GitHub Details
    $scriptBasePath = Join-Path $targetFolder -ChildPath $sampleAssetsFolder
    $scriptJson = Join-Path $scriptBasePath -ChildPath $jsonSample

    Write-Host " - JSON file: $scriptJson"

    $json = Get-Content $scriptJson | ConvertFrom-Json

    # Title
    $json[0].Title = $ScriptTitle

    # Name
    $json[0].Name = $ScriptFolderName

    # Description
    $json[0].ShortDescription = $ScriptShortDescription
    
    # Url
    $json[0].Url = $json.Url.Replace("<foldername>", $ScriptFolderName)

    # Dates (created and modified)
    $json[0].creationDateTime = Get-Date -Format "yyyy-MM-dd"
    $json[0].updateDateTime = Get-Date -Format "yyyy-MM-dd"
    
    # Metadata
    $json[0].Metadata = @()
    switch ($ScriptTool) {
        "PnPPowerShell" { 
            $json[0].Metadata += [PSCustomObject]@{
                key = "PNP-POWERSHELL"
                value = "1.11.0"
            }
         }
        "CliForMicrosoft365" { 
            $json[0].Metadata += [PSCustomObject]@{
                key = "CLI-FOR-MICROSOFT365"
                value = "5.6.0"
            }
         }
        "CliForMicrosoft365Bash" {
            $json[0].Metadata += [PSCustomObject]@{
                key = "CLI-FOR-MICROSOFT365"
                value = "5.6.0"
            }
         }
        "SPOManagementShell" {
            $json[0].Metadata += [PSCustomObject]@{
                key = "SPO-MANAGEMENT-SHELL"
                value = "16.0.21116.12000"
            }
        }
        "MicrosoftGraphPowerShell" { 
            $json[0].Metadata += [PSCustomObject]@{
                key = "GRAPH-POWERSHELL"
                value = "1.0.0"
            }
         }
        "AzureCli" { 
            $json[0].Metadata += [PSCustomObject]@{
                key = "AZURE-CLI"
                value = "2.27.0"
            }
        }
        "PowerAppsPowerShell" { 
            $json[0].Metadata += [PSCustomObject]@{
                key = "POWERAPPS-POWERSHELL"
                value = "2.0.0"
            }
        }
        "MicrosoftTeamsPowerShell" { 
            $json[0].Metadata += [PSCustomObject]@{
                key = "MICROSOFTTEAMS-POWERSHELL"
                value = "3.0.0"
            }
        }
        Default {}
    }

    # Thumbnails
    $json[0].Thumbnails[0].Url = $json.Thumbnails[0].Url.Replace('<foldername>', $ScriptFolderName)
    $json[0].Thumbnails[0].Alt = $json.Thumbnails[0].Alt.Replace('<title>', $ScriptTitle)
    
    # Authors
    $json[0].authors[0].gitHubAccount = $GitHubId
    $json[0].authors[0].pictureUrl = $json.authors[0].pictureUrl.replace("<github-username>", $GitHubId)
    $json[0].authors[0].Name = $AuthorFullName

    # References
    $json[0].References = @()
    switch ($ScriptTool) {
        "PnPPowerShell" { 
            $json[0].References += $tabBlocks.PnPPowerShell.Reference
         }
        "CliForMicrosoft365" { 
            $json[0].References += $tabBlocks.CliForMicrosoft365.Reference
         }
        "CliForMicrosoft365Bash" {
            $json[0].References += $tabBlocks.CliForMicrosoft365.Reference
         }
        "SPOManagementShell" {
            $json[0].References += $tabBlocks.SPOManagementShell.Reference
        }
        "MicrosoftGraphPowerShell" { 
            $json[0].References += $tabBlocks.MicrosoftGraphPowerShell.Reference
         }
        "AzureCli" { 
            $json[0].References += $tabBlocks.AzureCli.Reference
        }
        "PowerAppsPowerShell" { 
            $json[0].References += $tabBlocks.PowerAppsPowerShell.Reference
        }
        "MicrosoftTeamsPowerShell" { 
            $json[0].References += $tabBlocks.MicrosoftTeamsPowerShell.Reference
        }
        Default {}
    }

    # Save Sample.json file
    $jsonArr = [System.Collections.ArrayList]@()
    $jsonArr += $json
    ConvertTo-Json -InputObject $jsonArr -Depth 10 | Out-File $scriptJson

    Write-Host " - Populated the sample.json file in $targetFolder/assets"

    $finalPath = Join-Path -Path "$(Get-Location)" -ChildPath $targetFolder
    Write-Host " Sample setup complete, please go to $finalPath " -ForegroundColor Cyan

}
end{
    Write-Host "`n---- Done! :) ----" -ForegroundColor Green
}