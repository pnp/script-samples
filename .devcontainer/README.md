# Work on the gallery in a dev container

Open the repository in a VS Code dev container or GitHub Codespaces. The container includes Node.js 22, PowerShell, GitHub CLI, and Azure CLI, and installs the gallery's locked dependencies.

From the repository root:

```shell
npm --prefix site run dev
```

Open the forwarded port at `/script-samples/`. To check your changes:

```shell
npm --prefix site test
npm --prefix site run build
```

Browser tests need Chromium installed once with `npx playwright install chromium` from the `site` directory. Run them with `npm --prefix site run test:e2e`.

You do not need to build the gallery to contribute a script. Follow the [contribution guide](../docs/contributing/preparing-a-submission.md).
