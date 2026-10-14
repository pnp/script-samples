# Script samples framework

## Creating a sample

- When helping create a new sample, use [`New-Sample.ps1`](../New-Sample.ps1) from the repository root to scaffold it. The sample template is in [`scripts/_template-script-submission`](../scripts/_template-script-submission/).
- Use the generator's supported tool values, such as `PnPPowerShell`, `CliForMicrosoft365`, `SPOManagementShell`, `CliForMicrosoft365Bash`, `MicrosoftGraphPowerShell`, `AzureCli`, `PowerAppsPowerShell`, and `MicrosoftTeamsPowerShell`.
- Example:

  ```powershell
  .\New-Sample.ps1 -ScriptFolderName "spo-get-list-items" `
      -ScriptTitle "Generate a list of SharePoint Sites" `
      -ScriptShortDescription "This script generates a list of SharePoint sites using the specified tool." `
      -ScriptTool PnPPowerShell `
      -AuthorFullName "Paul Bullock" `
      -GitHubId "pkbullock"
  ```

- Add each script to the matching tool tab in the generated `README.md`, replace its `<your script>` placeholder, and remove unused tabs. The tool can use PowerShell, Bash, or another supported language.
- A sample requires `README.md`, `assets/sample.json`, and `assets/preview.png`. The README screenshot is optional; the template includes `assets/example.png`. If scaffolding manually, copy `assets/template.sample.json` to `assets/sample.json` and fill in its metadata.
- Remove credentials, usernames, and tenant-specific details from sample scripts. For scripts that delete or remove data, add a clear warning describing the impact before the script.
- The final line of every script-root `README.md` must be the visitor-tracking image. Set its `src` to `https://m365-visitor-stats.azurewebsites.net/script-samples/{script-path}`, replacing `{script-path}` with the repository-relative sample directory, for example `scripts/spo-get-list-items`. Preserve existing attributes such as `aria-hidden` when present.
- For the full submission workflow and requirements, see the [contribution guide](../docfx/contributing/preparing-a-submission.md). For scaffolding an existing script submission, follow the [sample-scaffolder skill](skills/sample-scaffolder/SKILL.md).
