# ============================================================
# Dataverse Security Role Assignment Checker
# ============================================================

$orgUrl = "https://org4131a97e.crm4.dynamics.com"
$maxUsers = 500

Write-Host "Getting Access Token..." -ForegroundColor Cyan
$tokenObj = Get-AzAccessToken -ResourceUrl $orgUrl
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tokenObj.Token)
)

if (-not $token) {
    Write-Error "Could not retrieve token. Please run 'Connect-AzAccount' first."
    exit
}

$headers = @{
    Authorization      = "Bearer $token"
    "OData-MaxVersion" = "4.0"
    "OData-Version"    = "4.0"
    Accept             = "application/json"
}

Write-Host "Loading users..." -ForegroundColor Cyan

$usersUrl = "$orgUrl/api/data/v9.2/systemusers?`$select=fullname,domainname,isdisabled&`$filter=isdisabled eq false and domainname ne ''&`$expand=systemuserroles_association(`$select=name)&`$top=$maxUsers"

try {
    $response = Invoke-RestMethod -Uri $usersUrl -Headers $headers -Method Get
}
catch {
    Write-Error "API call failed: $_"
    exit
}

$users = $response.value | Where-Object { 
    $_.fullname -notlike "#*" -and 
    $_.domainname -notlike "*@microsoft.com" 
}

Write-Host "$($users.Count) users loaded." -ForegroundColor Cyan

$directAssignment = @()
$noDirectAssignment = @()

foreach ($user in $users) {
    $roles = $user.systemuserroles_association
    $roleNames = if ($roles -and $roles.Count -gt 0) {
        ($roles | ForEach-Object { $_.name }) -join ", "
    }
    else { "" }

    $obj = [PSCustomObject]@{
        Name     = $user.fullname
        Username = $user.domainname
        Roles    = $roleNames
    }

    if ($roles -and $roles.Count -gt 0) {
        $directAssignment += $obj
    }
    else {
        $noDirectAssignment += $obj
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Red
Write-Host " USERS WITH DIRECT ROLE ASSIGNMENT ($($directAssignment.Count))" -ForegroundColor Red
Write-Host "================================================" -ForegroundColor Red
if ($directAssignment.Count -gt 0) {
    $directAssignment | Format-Table
}
else {
    Write-Host "No users with direct assignment found." -ForegroundColor Green
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host " USERS WITHOUT DIRECT ASSIGNMENT - VIA GROUP ONLY ($($noDirectAssignment.Count))" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
$noDirectAssignment | Format-Table