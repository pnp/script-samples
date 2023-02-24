$scriptFolder = "script"
$sampleTemplate = "_template-script-submission"

# Copy the template to the script folder under the new name

# Request a foldername from the user
$folderName = Read-Host "Enter the folder name for the script e.g. spo-get-list-items or graph-export-teams"
$scriptTitle = Read-Host "Enter the title for the script e.g. Generate a list of SharePoint Sites"

# Request from user if they want to create a new script or update an existing one
$scriptAction = Read-Host "Do you want to create a new script or update an existing one? (new/update)"

$tabBlocks = @{
    "PnP-PowerShell" = $scriptTitle
    "Cli-For-Microsoft-365" = $scriptFolder
    "SPO-Management-Shell" = $scriptAction
}


function New-ScriptInstance {
    param{
        [Parameter(Mandatory = $true)]
        [string]$newScriptFolderName
    }

    $templateSrc = "{0}\{1}" -f $scriptFolder, $sampleTemplate

    Copy-Item 

}




if ($scriptAction -eq "new") {
    <# Action to perform if the condition is true #>
    New-Script
}

if ($scriptAction -eq "update") {
    <# Action to perform if the condition is true #>
    Update-Script
}

# Update an existing script
function Update-Script {
    <# Function to update an existing script #>
}

# Create a new script
function New-Script {
    <# Function to create a new script #>
}

