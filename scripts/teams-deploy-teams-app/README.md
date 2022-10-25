---
plugin: add-to-gallery
---

# Deploy Microsoft Teams app from Azure DevOps

## Summary

Installs or updates a Microsoft Teams app from an Azure DevOps pipeline. Deploys the app if it hasn't been deployed yet or updates the existing package if it's been previously deployed.
 
# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
m365 login -t password -u $(username) -p $(password)

$apps = m365 teams app list -o json | ConvertFrom-Json
$app = $apps | Where-Object { $_.externalId -eq $env:APPID}
if ($app -eq $null) {
  # install app
  m365 teams app publish -p  $(System.DefaultWorkingDirectory)/teams-app-CI/package/teams-app.zip
} else {
  # update app
  m365 teams app update -i $app.id -p $(System.DefaultWorkingDirectory)/teams-app-CI/package/teams-app.zip
}
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [CLI for Microsoft 365 with Bash](#tab/m365cli-bash)
```bash
m365 login -t password -u $(username) -p $(password)

app=$(m365 teams app list -o json | jq '.[] | select(.externalId == "'"$APPID"'")')

if [ -z "$app" ]; then
  # install app
  m365 teams app publish -p "$(System.DefaultWorkingDirectory)/teams-app-CI/package/teams-app.zip"
else
  # update app
  appId=$(echo $app | jq '.id')
  m365 teams app update -i $appId -p "$(System.DefaultWorkingDirectory)/teams-app-CI/package/teams-app.zip"
fi
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Deploy Microsoft Teams app from Azure DevOps | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/teams/deploy-teams-app/)

## Contributors

| Author(s) |
|-----------|
| Garry Trinder |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/teams-deploy-teams-app" aria-hidden="true" />
