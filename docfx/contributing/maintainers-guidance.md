# Maintainers Guidance

This is the maintainers guide to provide a location to share knowledge about how the site works and some of the behaviors of the setup and underlying configuration.

## Docfx

The site uses the DocFx engine, this is the same tool that [learn.microsoft.com](https://learn.microsoft.com) uses (albeit a special version) in combination with the Material UI + UI tweaks we have made with the help and thanks for Hugo Bernier.

- Install DocFx from GitHub [DocFx Releases](https://github.com/dotnet/docfx/releases).
- Ensure that ```docfx``` command can run from anywhere, add the installation location to my environment variables if it does not run.
- Clone the site with ```git clone https://github.com/pnp/script-samples.git```
- Find a script called ```docfx-build-local.ps1``` running under the docfx folder will build the site. 
- View the site locally, ```docfx docfx.json --serve```, alternatively, I use an npm module called ```http-server``` run that on the generated _site location to see it render.

The main goal with DocFx builds must complete with **0 warnings and errors**. The site will not publish/update if there are warnings.


## Galleries

Currently, there are 3 pages that galleries are used:

* Index.md - default gallery page
* by-tool.md - By Library gallery page e.g. M365 CLI, PnP PS, Graph PS SDK etc.
* by-product.md - By Product e.g. Microsoft Product the script performs an action against

The card style uses Isotope.js with CSS/HTML to show the card format, but it can adapt to screen resolution and adjust the number of cards accordingly.

## Folder Structure for scripts

We have worked to keep the folder structure lean and as simple as possible when submitting scripts:

![Folder Structure](../assets/contributing/folder-structure.png)

## Naming and casing

DocFx is case sensitive with the markdown files and in compilation of the site, to make this easier, all sample file paths etc. should be in lowercase to avoid any issues with linking to files.

Spaces should be replaced with hyphens as well.

## Images and previews

When creating images and previews, please follow this guidance:

* Favor the product UI change, close up of the affect element if preferred, to reduce the updates
* If delete, show a before image and indicate what is being removed.
* Terminal is less favorable because it would only show output of 1 of the three types of script that could run.
* PNG format preferred, JPG can be submitted, though these will be converted to PNG.

If only example images are shown, Paul Bullock has a tool to convert in bulk.

## Recognizing contributors

When samples are submitted it is important that contributors are recognized for their contributions as without them the library would not grow, this is done in the following ways:

* Their name on the sample. If we as a maintainer also contributes to the article, they must be the primary or first name.
* The article must list their name, company and GitHub/LinkedIn/Twitter handle - we will encourage their complete this.
* Promotion to X, BlueSky, LinkedIn & Discord  - their sample will get promoted in these locations for greater exposure.

## Reports

There are a series of reports that are generated to help with the maintenance of the site, these are:

* [Matrix of Sample Distribution by Tool](https://pnp.github.io/script-samples/matrix.html)
* [Report of Samples Command Usage](https://pnp.github.io/script-samples/cmdusage.html)
* [Metadata Report of Samples](https://pnp.github.io/script-samples/metadata.html)
* [Age Report of Samples](https://pnp.github.io/script-samples/age.html)

<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/contributing/maintainers-guidance" aria-hidden="true" />
