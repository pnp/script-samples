# Preparing a submission

Thank you for considering contributing to this repository. In order to help you get started, we have prepared this guide to provide you with the information you need to prepare your submission.

>[!Note]  
> If you miss anything on your submission, please don't worry, we will check and make the tweaks to the submission for you, we may reach out within the Pull Request to check some details with you. We do not want to put you off contributing, we want to make it as easy as possible for you to contribute.

## Where Do I Start?

First, you need to ensure you have a GitHub account. If you don't have one, you can create one for free.
Then find the repository at [https://github.com/pnp/script-samples](https://github.com/pnp/script-samples) and click the ["Fork"](https://docs.github.com/en/get-started/quickstart/fork-a-repo) button in the top right corner.

Before you can submit, you need to make sure you are setup with a "fork" of the repository in your own account, please navigate to [Submitting Pull Requests](submitting-pull-requests.md) for setup information.

### Submission Template Files

There is a template submission folder called **"_template-script-submission"** in [_template-script-submission | GitHub - PnP Script Samples](https://github.com/pnp/script-samples/tree/main/scripts/_template-script-submission).

The template submission folder contains:

- **README.md** - Sample Readme with the structure, remove the dummy text and update the areas for your submission
- **assets/example.png** - image for the sample, simply replace with a screenshot to show in the article

> [!note]
> If you would like an example, please refer to the following script: [Generate Demo Events for SharePoint Events List | PnP Script Samples](https://pnp.github.io/script-samples/spo-generate-demo-events/README.html) <br />
> Please note: this isn't an expected sample style, quality or format, or a gold standard just an idea if you feel you need some ideas on how to present your script. <br /><br />
> We fully understand that there any multiple styles and approaches, and __we are happy to accept the submission in your style__ 😊

## Page Structure

The page follows a standard format, we have created a graphic to explain the layout and the markdown for each section:

> [!div class="full-image-size"]
> ![Page Layouts and Markdown](../assets/contributing/page-layouts.png)

The minimum we need for the submission is:

- **Article Title** - the title for your script
- **Summary** - for briefly describing what the script does
- **Image**, ideally named "example.png" in an assets folder, presenting the end result of the operation. The more visual the better.
- **Script** - minimum of at least one type. We support a wide range of script types, if this is not listed in the template file, we can add support for that type when you submit your PR.
- **Contributors** - your name, or if a joint submission those you have worked with - so that we can attribute credit for the submission.

We add the disclaimer statement at the bottom.

### What is Markdown?

This repository uses a text based markup called "Markdown" which allows you to write articles/pages quickly without having to worry about the presentation of the page. Even this page is written using this - we use a site generator to turn this into a page automatically.

If you want to learn more about Markdown checkout this guide by Bob German on Tech Community - [What's up with Markdown?](https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/what-s-up-with-markdown/ba-p/2323834)

### Key elements of Markdown we use

```markdown

# Heading 1
## Heading 2
### Heading 3


| Table Header |
|--------------|
| Table Data   |


[Hyperlink](https://bing.co.uk)

![Example Screenshot](assets/example.png)

```

### Tabs containing scripts

Each tab contains the sample for the scripts named under a specific tool. Use the following markdown to contain the script in the tab:

```markdown

# [PnP PowerShell](#tab/pnpps)
``powershell
    Your-PowerShellScript
``

# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)
`` powershell
    Your-PowerShellScript
``

# [CLI for Microsoft 365 using Bash](#tab/cli-m365-bash)
``bash
    echo "your bash script"
``

# [Microsoft Graph PowerShell](#tab/graphps)
``powershell
    Your-PowerShellScript
``

```

> [!note]
> * Use three backticks around the script, not the two shown above
> * Delete the tabs you do not need


We add an additional block to provide guidance back to the tool guiding site:

```markdown
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
```

## Optional files

- **assets/template.sample.json** - this is a metadata file used for the gallery views, this is optional *DO NOT HAVE TO COMPLETE THIS*
- **assets/preview.png** - we generate a preview from the example.png file, you do not have to update this.

## Folder Structure

We have worked to keep the folder structure lean and as simple as possible when submitting scripts:

```markdown

+--- script-folder-title - *folder for the script based on the title of your sample, please all lowercase and spaces as hyphens*
  |___ assets - *sub folder for any images or assets you need to support your sample*
```
![Folder structure](../assets/contributing/folder-structure-contributors.png)

## Sample Naming and Structure Guidelines

When you are submitting a new sample, it has to follow up below guidelines

### ReadMe File

You will need to have a `README.md` file for your contribution, which is based on [the provided template](/../scripts/template-script-submission/README.md) under the `scripts` folder. Please copy this template to your project and update it accordingly. Your `README.md` must be named exactly `README.md` -- with capital letters -- as this is the information we use to make your sample public.

Please update the image source at the bottom of the template, the `src` attribute according with the repository name and folder information. For example, if your sample is named `sampleA` in the `scripts` folder, you should update the `src` attribute to `https://pnptelemetry.azurewebsites.net/script-samples/scripts/sampleA`

We use this for tracking your samples usage and popularity.

### Screenshot (optional)

You will need to have a screenshot picture of your sample in action in the `README.md` file ("pics or it didn't happen"). The preview image must be located in the `/assets/` folder in the root your you solution.

### Sample Updates

You are free to submit updates to existing samples, if you find an issue or could benefit from improvements.

When you update existing samples, please update also `README.md` file accordingly with information on provided changes and with your author details

### Sample Folder Naming

When submitting a new sample solution, please name the sample solution folder accordingly

Do not use words such as `sample`, `script` or `ps` in the folder or sample name

Do not use period/dot in the folder name of the provided sample

### Remove environment or sensitive details

Please be sure to remove all of your password, usernames and tenant addresses from the sample scripts - this is to maintain the security of your tenant. Examples include replacing the organisation name with Contoso e.g. https://contoso.sharepoint.com giving the details of the type of address but hiding the key information.

### Destructive scripts

We are happy to accept scripts that bulk delete or remove, delete an artefact but we will add a warning message to ensure that the reader is aware to ensure they understanding the implications of running the script.

e.g.

> [!Warning]
> Please be aware this script contains a command that will remove or delete an artefact, ensure you test and understanding the implications of running the script.

### We Track the Samples Usage

The `README` template contains a specific tracking image at the bottom of the file with an `img` tag, where the `src` attribute points to `https://pnptelemetry.azurewebsites.net/script-samples/samples/readme-template`. This is a transparent image which is used to track viewership of individual samples in GitHub.

<img src="https://pnptelemetry.azurewebsites.net/script-samples/contributing/preparing-a-submission" aria-hidden="true" />