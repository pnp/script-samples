$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$fixture = Join-Path ([System.IO.Path]::GetTempPath()) ("script-samples-generator-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path (Join-Path $fixture 'scripts') | Out-Null
try {
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'New-Sample.ps1') -Destination $fixture
    Copy-Item -LiteralPath (Join-Path $repositoryRoot 'scripts\_template-script-submission') -Destination (Join-Path $fixture 'scripts\_template-script-submission') -Recurse
    $generator = Join-Path $fixture 'New-Sample.ps1'
    $arguments = @{
        ScriptFolderName = 'spo-generator-check'
        ScriptTitle = 'Generator check'
        ScriptShortDescription = 'A temporary generator validation fixture.'
        ScriptTool = 'All'
        AuthorFullName = 'Example Contributor'
        GitHubId = 'example-contributor'
    }
    & $generator @arguments
    $sample = Join-Path $fixture 'scripts\spo-generator-check'
    $readmePath = Join-Path $sample 'README.md'
    $readme = Get-Content -LiteralPath $readmePath -Raw
    $metadata = @(Get-Content -LiteralPath (Join-Path $sample 'assets\sample.json') -Raw | ConvertFrom-Json)[0]
    if ([regex]::Matches($readme, '(?m)^# \[.+\]\(#tab/').Count -ne 8) { throw 'All must generate eight code tabs.' }
    if (@($metadata.metadata).Count -ne 7) { throw 'All must generate seven unique tool keys, with CLI shared by PowerShell and Bash.' }
    if ($readme -match '\.\./\.\./docfx/') { throw 'Generator must use the migrated shared include paths.' }
    if ($readme.TrimEnd().Split("`n")[-1] -notmatch 'script-samples/scripts/spo-generator-check') { throw 'Incorrect final view tracker.' }
    $original = Get-FileHash -LiteralPath $readmePath
    $rejected = $false
    try { & $generator @arguments } catch { $rejected = $_.Exception.Message -like '*already exists*' }
    if (-not $rejected) { throw 'Generator must reject existing sample folders.' }
    if ((Get-FileHash -LiteralPath $readmePath).Hash -ne $original.Hash) { throw 'An existing sample was modified.' }
    $arguments.ScriptFolderName = 'spo-cli-check'
    $arguments.ScriptTool = @('CliForMicrosoft365', 'CliForMicrosoft365Bash')
    & $generator @arguments
    $cli = @(Get-Content -LiteralPath (Join-Path $fixture 'scripts\spo-cli-check\assets\sample.json') -Raw | ConvertFrom-Json)[0]
    if (@($cli.metadata).Count -ne 1) { throw 'CLI variants must not duplicate metadata keys.' }
    Write-Host 'Generator checks passed: all tools, unique metadata, migrated includes, tracker, and overwrite protection.'
} finally {
    Get-ChildItem -LiteralPath $fixture -Recurse -File | Remove-Item -Force
    Get-ChildItem -LiteralPath $fixture -Recurse -Directory | Sort-Object { $_.FullName.Length } -Descending | Remove-Item -Force
    Remove-Item -LiteralPath $fixture -Force
}
