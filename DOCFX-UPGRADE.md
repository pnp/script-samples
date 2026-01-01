# DocFx Upgrade Guide

## Overview

This repository has been upgraded from **DocFx 2.56.7** to **DocFx 2.78.4**. The upgrade modernizes the documentation build process while maintaining the existing material theme look and feel.

## What Changed

### Build System
- **Before**: DocFx 2.56.7 installed as a standalone executable requiring Mono on Linux/macOS
- **After**: DocFx 2.78.4 installed as a .NET tool, no Mono dependency required

### Benefits
- ✅ Cross-platform compatibility without Mono
- ✅ Easier installation and updates via .NET tooling
- ✅ Better performance and stability
- ✅ Active maintenance and bug fixes
- ✅ Material theme fully preserved
- ✅ All existing features maintained

## Local Development Setup

### Prerequisites
- .NET SDK 6.0 or higher ([Download here](https://dotnet.microsoft.com/download))

### First Time Setup
1. Clone the repository
2. Navigate to the repository root
3. Restore the DocFx tool:
   ```bash
   dotnet tool restore
   ```

### Building the Documentation

#### Quick Build
From the `docfx` folder:
```bash
dotnet docfx build docfx.json
```

Or use the provided script:
```powershell
./docfx-build-local.ps1
```

#### Build and Serve Locally
To preview the site locally:
```bash
cd docfx
dotnet docfx docfx.json --serve --port 8080
```

Then open your browser to `http://localhost:8080`

### CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/docfx-generate.yml`) has been updated to:
1. Use `actions/setup-dotnet@v4` to install .NET SDK
2. Run `dotnet tool restore` to install DocFx
3. Execute the build using `dotnet docfx`

No changes needed for manual deployments - the workflow handles everything automatically.

## Theme Information

The site uses a custom material theme based on [Oscar Vasquez's DocFx Material theme](https://ovasquez.github.io/docfx-material/).

### Theme Files
- `docfx/templates/material/` - Custom theme templates
  - `layout/_master.tmpl` - Main layout template
  - `partials/` - Reusable template components (navbar, footer, head, etc.)
  - `styles/` - Custom CSS and JavaScript files

### Color Scheme
The theme uses a cyan color palette defined in `styles/main.css`:
- Header background: `#006064` (dark cyan)
- Highlight light: `#428e92` (teal)
- Highlight dark: `#00363a` (very dark cyan)

## Troubleshooting

### "docfx: command not found"
Make sure you've run `dotnet tool restore` in the repository root.

### Build Errors
1. Verify .NET SDK is installed: `dotnet --version`
2. Clean the output folder: `rm -rf docfx/_site`
3. Rebuild: `cd docfx && dotnet docfx build docfx.json`

### Theme Not Applied
The theme files should be automatically copied during build. Check that `docfx/templates/material/` folder exists and contains the template files.

## Plugin Notes

The `docfx/plugins/DocFx.Plugin.ExtractFrontMatter.dll` plugin is legacy and **not currently used** by the build process. DocFx 2.78.4 uses its built-in plugins only.

## Version History

| Date | DocFx Version | Notes |
|------|---------------|-------|
| 2024-01 (Previous) | 2.56.7 | Mono-based installation |
| 2026-01 (Current) | 2.78.4 | .NET tool-based installation |

## Additional Resources

- [DocFx Official Documentation](https://dotnet.github.io/docfx/)
- [DocFx GitHub Repository](https://github.com/dotnet/docfx)
- [.NET SDK Downloads](https://dotnet.microsoft.com/download)
