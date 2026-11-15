# Astro gallery migration

This package replaces the DocFX build with the approved Community Script Samples design. The existing published site does not change until the repository owner merges the change and enables the new GitHub Pages deployment.

## Included in the package

- Static Astro/TypeScript site with Parker branding, Microsoft blue, the shared community navigation/color bar, and persistent light/dark mode.
- Full source catalog: 419 samples at migration time, including complete README content, 607 tool tabs, and 674 code blocks. Source scripts are not executed.
- Product imagery and count-ordered quick filters, combined command/alias search, tool/scenario/author filters, grid/list views, progressive results, and restored browsing context.
- Contributor profiles and the supplied Credly badge. A malformed duplicate author account was corrected from other matching source records, resulting in 107 distinct accounts.
- Approachable supporting guides, the sample generator, and build-time maintenance reports.
- Read-only PR checks and a separate, upstream-only GitHub Pages deployment.

## Legacy content and data repairs

The useful guides, assets, shared includes, and command-help index moved from `docfx/` to `docs/`. Existing include statements were updated. The renderer still understands the established tool-tab and include syntax, so authors do not need to learn Astro.

The obsolete DocFX configuration, templates, plugins, generated-report scripts, .NET tool manifest, and container setup were removed. The command-help refresh tooling remains under `tooling/`.

Catalog validation exposed and repaired legacy issues rather than excluding samples:

- Invalid JSON trailing commas, null description/reference fields, and inconsistent tool-key casing.
- Folder/metadata identities, historical aliases, cross-sample or missing preview references, and missing preview alt text.
- Topic/command values in product/category fields: these were preserved as tags, with scenarios mapped to the established category vocabulary.
- A missing summary was taken from the existing README. One impossible content-date ordering was corrected using the metadata migration date; this does not assert that the script was retested.
- Incorrect or multiline final README trackers were corrected to each sample's own path while retaining accessibility attributes.

## URL and asset compatibility

- Every legacy `/<sample>/README.html` URL redirects to `/samples/<sample>/`.
- Known historical metadata aliases are retained in `content/legacy-aliases.json`.
- Old guide `.html` paths redirect to their canonical pages.
- By-product, by-tool, and compact-view URLs redirect to the unified catalog. Existing search query parameters are carried forward.
- The matrix, metadata, command-usage, and age-report URLs point to the corresponding report section.
- Local sample assets, downloadable files, and retained documentation assets keep their historical public paths.
- `samples.json` remains available, and `catalog.json` exposes the new public catalog.

Redirects preserve query/fragment context and emit no tracking image. Canonical views each have exactly one tracker identity; source README trackers are removed from rendered Markdown. Local/PR previews cannot send production tracking requests.

## Owner action before deployment

1. Review the PR's catalog, generator, Astro build, link/redirect/tracker, desktop/mobile, and accessibility checks.
2. Set **Settings > Pages > Build and deployment > Source** to **GitHub Actions** when ready to cut over from the old `gh-pages` branch.
3. Allow the `github-pages` deployment environment to deploy from `main`, and merge the package.
4. Confirm the deployment workflow succeeds and verifies its commit using `/script-samples/deployment.json`.
5. Smoke-test an old sample link, filtering and browser back, a multi-tool sample, contributors, badge guidance, and the 404 page.

The workflow deliberately does not deploy from personal forks. No repository settings are changed automatically by this package.

## Local checks

From the repository root:

```powershell
npm --prefix site ci
npm --prefix site test
pwsh -NoProfile -File .\site\tests\generator.ps1
npm --prefix site run build
```

For browser checks, run `npx playwright install chromium` from `site`, then `npm run test:e2e`. `npm run dev` serves local development at `/script-samples/`.
