# Help maintain a welcoming gallery

Maintainers help people share useful work, keep samples discoverable, and make contribution a good experience. Thank contributors, explain requested changes, and distinguish blocking problems from optional suggestions.

## Review a contribution

- Check the scenario, expected result, prerequisites, permissions, and tested tool versions.
- Confirm each advertised tool tab contains a complete implementation and no submission placeholders.
- Check for credentials and private tenant or personal information. Ensure destructive operations have an impact warning before the script.
- Review metadata, preview images/alt text, and author attribution. Use Microsoft Copilot as that product's name.
- Keep original authors credited; add meaningful contributors alongside them. Company and social accounts are optional.
- Confirm the sample's final README tracker uses its own repository-relative directory, including exact casing.
- Help contributors resolve issues in their change. Do not ask them to repair unrelated samples.

The [preparation guide](preparing-a-submission.md) is the contributor-facing checklist. Schema and build checks catch structural problems; they do not prove a script is safe or independently tested.

## Run the Astro gallery locally

Use Node.js 22.19 or later. No .NET or DocFX installation is needed.

From the repository root:

```powershell
npm --prefix site ci
npm --prefix site run dev
```

Open `http://localhost:4321/script-samples/`. The gallery uses a static Astro build, TypeScript, local fonts, sanitized Markdown, Shiki code highlighting, and small browser scripts. It does not execute sample code or require a runtime GitHub API.

## Validate before merging

```powershell
npm --prefix site run validate:samples
npm --prefix site test
pwsh -NoProfile -File .\site\tests\generator.ps1
npm --prefix site run build
```

For browser tests, install Chromium once from the site directory:

```powershell
Set-Location .\site
npx playwright install chromium
npm run test:e2e
```

PR validation runs with read-only permissions. It checks all sample records, source assets, README trackers, generator behavior, complete Markdown/tool-tab rendering, Astro types, the production build, internal links/fragments, redirects, keyboard interactions, mobile layouts, and accessibility.

The generated catalog, public sample copies, build output, and browser diagnostics are ignored. Do not commit them.

## Content and compatibility

- `scripts/<sample>/README.md` and `assets/sample.json` remain the sample source of truth.
- `docs/` holds contributor guides, shared includes, and retained assets. Keep shared include statements pointing to `../../docs/includes/`.
- `site/scripts/config.mjs` defines product aliases, tool labels, and scenario categories. Unknown products fail validation rather than silently disappearing.
- The renderer supports existing tool tabs, admonitions, tables, relative images/downloads, and shared includes. It strips source view trackers before adding the page tracker.
- Existing `/<sample>/README.html` URLs redirect to `/samples/<sample>/`. Old by-product/by-tool/compact pages redirect to equivalent gallery state.
- Static sample assets retain their historical paths. Command tags link to tool documentation when the retained help index knows the command.

Historical mixed-case sample folders remain addressable. New generator folder names are lowercase with hyphens, and existing folders cannot be overwritten.

## View tracking

Each rendered view has one hidden image with its canonical identity. Sample pages retain `script-samples/scripts/<sample>`; the home page retains `script-samples`. Redirect pages emit no tracker, preventing double counting.

Local and PR builds do not send production analytics. Production tracking requires both `PUBLIC_ENABLE_VIEW_TRACKING=true` at build time and the `pnp.github.io/script-samples/` hostname/path at runtime. Filtering, sorting, theme changes, and layout changes do not create new page views.

## GitHub Pages cutover

The new deployment workflow replaces the old DocFX/`gh-pages` build. The repository owner must set **Settings > Pages > Build and deployment > Source** to **GitHub Actions** for the cutover. This is a repository setting, not something a contributor's PR changes automatically.

The deployment workflow runs on `main` in `pnp/script-samples`, uploads the static artifact, deploys to the `github-pages` environment, and verifies the published commit using `deployment.json`. Fork branches run no production deployment.

Review the [migration notes](../../site/MIGRATION.md) before the first release. Keep the existing published site available until the new artifact has passed validation and the owner is ready to change the Pages source.

## Recognize and amplify the work

Every sample contributor is eligible for the [Script Samples contributor badge](recognition.md) after their first accepted sample. Include the recognition-program opt-in link in a welcome or merge message; displaying artwork does not issue a credential.

After publication, check the sample's gallery page, thank the contributors, and share the published link. Consider a short community highlight explaining the scenario and tool, with author credit and no tenant details. Invite a [community call demo](https://aka.ms/community/request/demo) when the contributor wants to share the story.

Promotion depends on community schedules. Avoid promising fixed review, publication, or social-post turnaround.

[Contribution guidance](index.md) | [Contributor recognition](recognition.md) | [Catalog reports](https://pnp.github.io/script-samples/reports/) | [Community home](https://aka.ms/community/home)

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/contributing/maintainers-guidance" aria-hidden="true" />
