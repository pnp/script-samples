# Contributing

If you'd like to contribute to this repository, please read the following guidelines. Contributors are more than welcome to share their learnings with others in this centralized location.

The repository can be found at [https://github.com/pnp/script-samples](https://github.com/pnp/script-samples)

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

Remember that this repository is maintained by community members who volunteer their time to help. Be courteous and patient.

## Signing the CLA

Before we can accept your pull requests you will be asked to sign electronically Contributor License Agreement (CLA), which is a pre-requisite for any contributions all PnP repositories. This will be one-time process, so for any future contributions you will not be asked to re-sign anything. After the CLA has been signed, our PnP core team members will have a look at your submission for a final verification of the submission. Please do not delete your development branch until the submission has been closed.

You can find Microsoft CLA from the following address - https://cla.microsoft.com.

Thank you for your contribution.

> Sharing is caring.

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


## Getting Started for writing scenarios

### Using Markdown

TBC

### Folder Structure

We have worked to keep the folder structure lean and as simple as possible when submitting scenarios:

```markdown

| --- scenario-title - *folder for the scenario*
    |--- assets - *folder for any images or assets you need to support your description*
    |--- scripts - *folder for the final scripts*

```

And that's it!

### Example scenario layouts

TBC

### Naming and casing

TBC

### Spell checker

TBC

### Preferred content layouts

### Descriptions

TBC

### Embedding scripts

TBC

### Adding an alterative script tab

TBC

### Images and previews

TBC

## Scenario Guidelines

TBC

### Remove environment or sensitive details

TBC

### Destructive scripts

TBC

## Recognition for your contribution

## Repository Maintainers

If you are interested in helping to maintain the repository please check out the [maintainers guidance](maintainers-guidance.md).


<img src="https://telemetry.sharepointpnp.com/script-samples/contributing" aria-hidden="true" />