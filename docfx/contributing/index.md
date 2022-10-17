# Contributing

If you'd like to contribute to this repository, please read the following guidelines. Contributors are **more than welcome** to share their learnings with others in this centralized location.

> [!NOTE]
> The repository can be found at [https://github.com/pnp/script-samples](https://github.com/pnp/script-samples)

## How can I contribute

There are ways to contribute:

* Create a scenario e.g. Upload a document to SharePoint, then add your script to the scenario
* Extend an existing scenario that does NOT have an example for the tool e.g. a scenario containing only CLI for Microsoft 365 sample, you can submit an updated scenario with a PnP PowerShell equivalent
* Logging an [issue in GitHub](https://github.com/pnp/script-samples/issues) if you have feedback about the site or samples

> [!div class="full-image-size"]
> ![Ways to contribute](../assets/contributing/ways-to-contribute.png)

To get started quickly, check out the [Preparing a submission guide](preparing-a-submission.md)

> *Please register your idea in the issue list and assign to yourself, there maybe others considering similar scripts.*

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

**Remember that this repository is maintained by community members who volunteer their time to help. Be courteous and patient.**

## Signing the CLA

Before we can accept your pull requests you will be asked to sign electronically Contributor License Agreement (CLA), which is a pre-requisite for any contributions all PnP repositories. This will be one-time process, so for any future contributions you will not be asked to re-sign anything. After the CLA has been signed, our PnP core team members will have a look at your submission for a final verification of the submission. **Please do not delete your development branch until the submission has been closed.**

You can find Microsoft CLA from the following address - https://cla.microsoft.com.

## Typos, Issues, Bugs and contributions

Whenever you are submitting any changes to the SharePoint repositories, please follow these recommendations.

* Always fork the repository to your own account before making your modifications
* Do not combine multiple changes to one pull request. For example, submit any samples and documentation updates using separate PRs
* If your pull request shows merge conflicts, make sure to update your local master to be a mirror of what's in the main repo before making your modifications
* If you are submitting multiple samples, please create a specific PR for each of them
* If you are submitting typo or documentation fix, you can combine modifications to single PR where suitable

## Sample Naming and Structure Guidelines

When you are submitting a new sample, it has to follow up below guidelines

* You will need to have a `README.md` file for your contribution, which is based on [the provided template](/../scripts/template-script-submission/README.md) under the `scripts` folder. Please copy this template to your project and update it accordingly. Your `README.md` must be named exactly `README.md` -- with capital letters -- as this is the information we use to make your sample public.
  * You will need to have a screenshot picture of your sample in action in the `README.md` file ("pics or it didn't happen"). The preview image must be located in the `/assets/` folder in the root your you solution.
* The `README` template contains a specific tracking image at the bottom of the file with an `img` tag, where the `src` attribute points to `https://telemetry.sharepointpnp.com/script-samples/samples/readme-template`. This is a transparent image which is used to track viewership of individual samples in GitHub.
  * Update the image `src` attribute according with the repository name and folder information. For example, if your sample is named `sampleA` in the `scripts` folder, you should update the `src` attribute to `https://telemetry.sharepointpnp.com/script-samples/scripts/sampleA`
* If you find an existing sample which is similar to yours, please extend the existing one rather than submitting a new similar sample
  * For example, if you use Office Graph with React, please add a new web part to the existing solution, rather than introducing a completely new solution
  * When you update existing samples, please update also `README.md` file accordingly with information on provided changes and with your author details
* When submitting a new sample solution, please name the sample solution folder accordingly
  * Do not use words such as `sample`, `script` or `ps` in the folder or sample name
  * If your solution is demonstrating multiple technologies, please use functional terms as the name for the solution folder
* Do not use period/dot in the folder name of the provided sample

## Remove environment or sensitive details

Please be sure to remove all of your password, usernames and tenant addresses from the sample scripts - this is to maintain the security of your tenant. Examples include replacing the organisation name with Contoso e.g. https://contoso.sharepoint.com giving the details of the type of address but hiding the key information.

### Destructive scripts

We are happy to accept scripts that bulk delete or remove, delete an artefact but we will add a warning message to ensure that the reader is aware to ensure they understanding the implications of running the script.

e.g.

> [!Warning]
> Please be aware this script contains a command that will remove or delete an artefact, ensure you test and understanding the implications of running the script.

## Repository Maintainers

If you are interested in helping to maintain the repository please check out the [maintainers guidance](maintainers-guidance.md).


<img src="https://pnptelemetry.azurewebsites.net/script-samples/contributing" aria-hidden="true" />