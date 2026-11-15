# Contribute to Community Script Samples

Share a useful script, add another tool implementation, improve the guidance, or report a reproducible problem. First-time contributors are welcome.

- [Create a sample with the generator](docs/contributing/preparing-a-submission.md).
- [Explore other ways to contribute](docs/contributing/how-can-i-contribute.md).
- [Open a focused pull request](docs/contributing/submitting-pull-requests.md).
- [Earn your Script Samples contributor badge](docs/contributing/recognition.md).
- [Get friendly, hands-on GitHub help](https://pnp.github.io/sharing-is-caring/).

The gallery is built with Astro, but you do not need to build the website to share a script. Sample content remains under `scripts/`, and shared guidance lives under `docs/`.

For website changes, use Node.js 22.19 or later:

```shell
npm --prefix site ci
npm --prefix site test
npm --prefix site run build
```

See the [maintainers guide](docs/contributing/maintainers-guidance.md) for browser tests, local development, deployment, and compatibility requirements.

Please follow the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
