<# 
----------------------------------------------------------------------------

    Title: Generate new Script Sample
    Website:

    References:

        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.3
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_argument_completion?view=powershell-7.3 
 
    .\New-Sample.ps1 -ScriptFolderName a-test-folder -ScriptTitle "Test Script" -ScriptTool PnPPowerShell -AuthorFullName "Paul Bullock" -GitHubId "pkbullock

----------------------------------------------------------------------------
#>

[CmdletBinding()]
param (

    [Parameter(Mandatory,
        HelpMessage = "The folder name for the script e.g. spo-get-list-items or graph-export-teams")]
    [Alias("FolderName")]
    [string] $ScriptFolderName,

    [Parameter(Mandatory,
        HelpMessage = "The title for the script e.g. Generate a list of SharePoint Sites")]
    [Alias("Title")]
    [string] $ScriptTitle,

    [ArgumentCompletions('PnPPowerShell', 'CliForMicrosoft365', 'SPOManagementShell', 'All')]
    [Parameter(Mandatory,
        HelpMessage = "The tool used to run the script e.g. PnP-PowerShell, Cli-For-Microsoft-365, SPO-Management-Shell")]
    [Alias("Tool")]
    [string] $ScriptTool,

    [Parameter(Mandatory,
        HelpMessage = "The name of the script author e.g. Paul Bullock")]
    [Alias("MyName", "Author")]
    [string] $AuthorFullName,

    [Parameter(Mandatory,
        HelpMessage = "Your GitHub ID, e.g. pkbullock, this is only for attribution on the sample")]
    [Alias("GHID", "AuthorId")]
    [string] $GitHubId

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
    $pluginName = "plugin: add-to-gallery-preparation"
    $readmeTitle = "# <title>"
    $readmeFile = "README.md"

    switch ($ScriptTool) {
        "PnPPowerShell" {  }
        "CliForMicrosoft365" {  }
        "SPOManagementShell" {  }
        "All" {  }
        Default {}
    }


    # Todo: Example on all the tool tab types
    $tabBlocks = @{
        "PnPPowerShell" = $scriptTitle
        "Cli-For-Microsoft-365" = $scriptFolder
        "SPO-Management-Shell" = $scriptAction
    }


    # ------------------------------------------------------------------------------
    # Introduction
    # ------------------------------------------------------------------------------

    Write-Host @"
    
    ██████  ███    ██ ██████      ███████  ██████ ██████  ██ ██████  ████████     ███████  █████  ███    ███ ██████  ██      ███████ ███████ 
    ██   ██ ████   ██ ██   ██     ██      ██      ██   ██ ██ ██   ██    ██        ██      ██   ██ ████  ████ ██   ██ ██      ██      ██      
    ██████  ██ ██  ██ ██████      ███████ ██      ██████  ██ ██████     ██        ███████ ███████ ██ ████ ██ ██████  ██      █████   ███████ 
    ██      ██  ██ ██ ██               ██ ██      ██   ██ ██ ██         ██             ██ ██   ██ ██  ██  ██ ██      ██      ██           ██ 
    ██      ██   ████ ██          ███████  ██████ ██   ██ ██ ██         ██        ███████ ██   ██ ██      ██ ██      ███████ ███████ ███████                                                                                                                  
"@

    Write-Host " Welcome to PnP Script Samples, this script will generate a new script sample" -ForegroundColor Green
    
    # ------------------------------------------------------------------------------
    
}
process {
    
    # Request from user if they want to create a new script or update an existing one
    # $scriptAction = Read-Host "Do you want to create a new script or update an existing one? (new/update)"

    # Copy the template to the script folder under the new name
    $templateSrc = "{0}\{1}" -f $mainScriptFolder, $sampleTemplateFolder
    $targetFolder = "{0}\{1}" -f $mainScriptFolder, $ScriptFolderName

    Copy-Item -Path $templateSrc -Destination $targetFolder -Recurse -Force
    Write-Host " Copied sample template to $targetFolder" -ForegroundColor Green

    # Create a new script from the template

    # Rename the template.sample.json file to sample.json
    $scriptJsonTemplate = "{0}\{1}\{2}" -f $targetFolder, $sampleAssetsFolder, $jsonSampleTemplate
    Rename-Item $scriptJsonTemplate -NewName $jsonSample


    # Update the script with the new information such as Title, FolderName, Tool


    # Update the sample.json file with the new information such as Title, FolderName, Tool, GitHub Details
    $scriptJson = "{0}\{1}\{2}" -f $targetFolder, $sampleAssetsFolder, $jsonSample


    # Request user navigate to the new folder
    

}
end{
    Write-Host "---- Done! :) ----" -ForegroundColor Green
}