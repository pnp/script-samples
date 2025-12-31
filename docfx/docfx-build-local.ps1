$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

# Data Generated Content
$runLocation  = Get-Location
#.\report-matrix.ps1 -BaseDir "$($runLocation)\..\"  -ReportFile "matrix.md"
#.\report-metadata.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "metadata.md"
#.\report-cmdusage.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "usage.md"
#.\report-age.ps1 -BaseDir "$($runLocation)\..\" -ReportFile "age.md"

Write-Host "Generating samples.json..." -ForegroundColor Cyan
$baseDir = (Resolve-Path (Join-Path $runLocation "..")).Path
./generate-samplesJson.ps1 -BaseDir $baseDir -ReportFile "samples.json"

# Main DocFX build
Write-Host "Building docfx..." -ForegroundColor Cyan
if($IsMacOs){

    <#
        Download DocFx and Install Mono if not already done.

            - https://github.com/dotnet/docfx/releases/tag/v2.56.7
            - https://www.mono-project.com/docs/getting-started/install/mac/

        Setup DocFx alias for MacOS

        1. In VS Code, create a new file (e.g., `docfx.sh`) to hold the wrapper script.  
        2. Add a wrapper to your script:  
        
        ```bash
        #!/bin/zsh
        mono /path/to/docfx.exe "$@"
        ```
        Replace `/path/to/docfx.exe` with the actual path.  
        3. Make it executable in your terminal: `chmod +x /path/to/docfx.sh`.  
        4. Move it to your PATH (e.g., `sudo mv /path/to/docfx.sh /usr/local/bin/docfx`).  
        5. Restart the VS Code integrated terminal so `docfx` is available as an alias-like command without hardcoding paths in your scripts.

    #>

    Write-Host "Running docfx on MacOS using mono..." -ForegroundColor Cyan
    bash docfx build docfx.json --warningsAsErrors $args

}else{

    <#
        Download DocFx and Install Mono if not already done.

            - https://github.com/dotnet/docfx/releases/tag/v2.56.7
            - Set the PATH environment variable to include the path to docfx.exe
                - Open System Properties > Advanced > Environment Variables
                - Under System Variables, find and select the 'Path' variable, then click 'Edit'
                - Click 'New' and add the full path to the directory containing 'docfx.exe'
                - Click 'OK' to save the changes
    #>

    Write-Host "Running docfx on Windows..." -ForegroundColor Cyan
    docfx build docfx.json --warningsAsErrors $args
}
