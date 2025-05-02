# Script samples framework

## Creating a sample

- A sample has the following structure:
    - README.md
    - assets/sample.json
    - assets/preview.png
- There is a template in .\scripts\\_template-script-submission

- The preferred way to create a sample is using PowerShell script to help users create a sample, called New-Sample.ps1 on the root of the repository. The script has the following example parameters:
    - Folder Name e.g. spo-get-list-items
    - Title e.g. Generate a list of SharePoint Sites
    - Description e.g. This script generates a list of SharePoint sites using the specified tool.
    - Tool e.g. PnPPowerShell
    - Author e.g. Paul Bullock
    - GitHub e.g. ID: pkbullock

- Example Script:
```powershell
.\New-Sample.ps1 -FolderName "spo-get-list-items" `
    -Title "Generate a list of SharePoint Sites" `
    -ShortDescription "This script generates a list of SharePoint sites using the specified tool." `
    -Tool PnPPowerShell `
    -AuthorFullName "Paul Bullock" `
    -GitHubId "pkbullock"
```

- When advising the user on how to create a sample, instruct them to use the New-Sample.ps1 script, then post their PowerShell into the tabs in the Readme.md file. There are placeholders called "<your script>".

- If the user needs more help, there is contribution guidance here: https://pnp.github.io/script-samples/contributing/index.html