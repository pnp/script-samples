# Share a script from an existing project

Already have a useful script in another repository or blog post? You do not need to start over or move the entire project. Bring the smallest complete example that helps someone solve the task.

## Make a self-contained sample

1. Make sure you have permission to share the code and assets under this repository's license. Preserve any required attribution.
2. Fork and clone [script-samples](https://github.com/pnp/script-samples), then create a contribution branch.
3. Use [New-Sample.ps1 and the preparation guide](preparing-a-submission.md) to create a new folder under **`scripts`**, not `samples`.
4. Adapt the script and its documentation. Include dependencies, tested tool versions, permissions, and a clear expected result. The sample should not depend on private files or your original repository being checked out.
5. Add a source-credit section linking to the original project, and credit its authors in the README and gallery metadata.
6. Replace private tenant details and credentials with safe placeholders. Add a warning before destructive operations and provide the gallery preview.
7. Test the adapted sample and [open a pull request](submitting-pull-requests.md).

If you use `-KeepSourceCredit` with the generator, it retains the template's example source-credit section. **Replace its example link with your actual source** before submitting.

## Keep the contribution focused

Do not copy an entire repository, its dependencies, build output, or unrelated history into the gallery. If preserving Git history or including several interdependent files is important, [discuss the approach with maintainers](https://github.com/pnp/script-samples/issues/new) first.

When the sample is published, share its gallery link from the original project so readers can find the maintained example. Every sample contributor is eligible for the [contributor badge](recognition.md).

[Browse the gallery](../index.md) | [Prepare a sample](preparing-a-submission.md) | [Get GitHub help](https://pnp.github.io/sharing-is-caring/)

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/contributing/merging-existing-project" aria-hidden="true" />
