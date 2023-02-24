$scriptFolder = "script"
$sampleTemplate = "script/_template-script-submission"

# Copy the template to the script folder under the new name

# Request a foldername from the user
$folderName = Read-Host "Enter the folder name for the script"
$scriptTitle = Read-Host "Enter the title for the script"

# Request from user if they want to create a new script or update an existing one
$scriptAction = Read-Host "Do you want to create a new script or update an existing one? (new/update)"

if ($scriptAction -eq "new") {
    <# Action to perform if the condition is true #>
}

if ($scriptAction -eq "update") {
    <# Action to perform if the condition is true #>
}

# Update an existing script


# Create a new script


