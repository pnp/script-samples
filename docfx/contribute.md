# Contributing

If you'd like to contribute to this repository, please read the following guidelines. Contributors are more than welcome to share their learnings with others in this centralized location.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

Remember that this repository is maintained by community members who volunteer their time to help. Be courteous and patient.

## Typos, Issues, Bugs and contributions

Whenever you are submitting any changes to the SharePoint repositories, please follow these recommendations.

* Always fork the repository to your own account before making your modifications
* Do not combine multiple changes to one pull request. For example, submit any samples and documentation updates using separate PRs
* If your pull request shows merge conflicts, make sure to update your local master to be a mirror of what's in the main repo before making your modifications
* If you are submitting multiple samples, please create a specific PR for each of them
* If you are submitting typo or documentation fix, you can combine modifications to single PR where suitable

## Sample Naming and Structure Guidelines

When you are submitting a new sample, it has to follow up below guidelines

* You will need to have a `README.md` file for your contribution, which is based on [the provided template](../scripts/template-script-submission/README.md) under the `scripts` folder. Please copy this template to your project and update it accordingly. Your `README.md` must be named exactly `README.md` -- with capital letters -- as this is the information we use to make your sample public.
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

## Submitting Pull Requests

Here's a high-level process for submitting new samples or updates to existing ones.

1. Sign the Contributor License Agreement (see below)
2. Fork this repository [pnp/script-samples](https://github.com/pnp/script-samples) to your GitHub account
3. Create a new branch from the `main` branch for your fork for the contribution
4. Include your changes to your branch
5. Commit your changes using descriptive commit message * These are used to track changes on the repositories for monthly communications
6. Create a pull request in your own fork and target the `main` branch
7. Fill up the provided PR template with the requested details

If you feel insecure about that process or are new to GitHub, please consider to attend the [Sharing Is Caring sessions from the PnP team](https://pnp.github.io/sharing-is-caring/#pnp-sic-events) in which the Microsoft 365 PnP team provides hands-on guidance for first time contributors.

Before you submit your pull request consider the following guidelines:

* Search [GitHub](https://github.com/pnp/script-samples/pulls) for an open or closed Pull Request
  which relates to your submission. You don't want to duplicate effort.
* Make sure you have a link in your local cloned fork to the [pnp/script-samples](https://github.com/pnp/script-samples)

  ```shell
  # check if you have a remote pointing to the Microsoft repo:
  git remote -v

  # if you see a pair of remotes (fetch & pull) that point to https://github.com/pnp/script-samples, you're ok... otherwise you need to add one

  # add a new remote named "upstream" and point to the Microsoft repo
  git remote add upstream https://github.com/pnp/script-samples.git
  ```

* Make your changes in a new git branch:

  ```shell
  git checkout -b sampleA master
  ```

* Ensure your fork is updated and not behind the upstream **script-samples** repo. Refer to these resources for more information on syncing your repo:
  * [GitHub Help: Syncing a Fork](https://help.github.com/articles/syncing-a-fork/)
  * [Keep Your Forked Git Repo Updated with Changes from the Original Upstream Repo](http://www.andrewconnell.com/blog/keep-your-forked-git-repo-updated-with-changes-from-the-original-upstream-repo)
  * For a quick cheat sheet:

    ```shell
    # assuming you are in the folder of your locally cloned fork....
    git checkout master

    # assuming you have a remote named `upstream` pointing official **script-samples** repo
    git fetch upstream

    # update your local master to be a mirror of what's in the main repo
    git pull --rebase upstream master

    # switch to your branch where you are working, say "sampleA"
    git checkout sampleA

    # update your branch to update it's fork point to the current tip of master & put your changes on top of it
    git rebase master
    ```

* Push your branch to GitHub:

  ```shell
  git push origin sampleA
  ```

## Merging your Existing GitHub Projects with this Repository

If the sample you wish to contribute is stored in your own GitHub repository, you can use the following steps to merge it with this repository:

* Fork the `script-samples` repository from GitHub
* Create a local git repository

    ```shell
    md script-samples
    cd script-samples
    git init
    ```

* Pull your forked copy of `script-samples` into your local repository

    ```shell
    git remote add origin https://github.com/yourgitaccount/powerplatform-samples.git
    git pull origin master
    ```

* Pull your other project from GitHub into the `samples` folder of your local copy of `script-samples`

    ```shell
    git subtree add --prefix=samples/projectname https://github.com/yourgitaccount/projectname.git master
    ```

* Push the changes up to your forked repository

    ```shell
    git push origin master
    ```

## Signing the CLA

Before we can accept your pull requests you will be asked to sign electronically Contributor License Agreement (CLA), which is a pre-requisite for any contributions all PnP repositories. This will be one-time process, so for any future contributions you will not be asked to re-sign anything. After the CLA has been signed, our PnP core team members will have a look at your submission for a final verification of the submission. Please do not delete your development branch until the submission has been closed.

You can find Microsoft CLA from the following address - https://cla.microsoft.com.

Thank you for your contribution.

> Sharing is caring.

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


<img src="https://telemetry.sharepointpnp.com/script-samples" aria-hidden="true" />