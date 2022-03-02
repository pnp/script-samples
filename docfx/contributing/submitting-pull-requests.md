# Submitting Pull Requests

## The process

Here's a high-level process for submitting new samples or updates to existing ones.

1. Sign the Contributor License Agreement
2. Fork this repository [pnp/script-samples](https://github.com/pnp/script-samples) to your GitHub account
3. Create a new branch from the `main` branch for your fork for the contribution
4. Include your changes to your branch
5. Commit your changes using descriptive commit message * These are used to track changes on the repositories for monthly communications
6. Create a pull request in your own fork and target the `main` branch
7. Fill up the provided PR template with the requested details

## Want to practice the setup?

If you feel insecure about that process or are new to GitHub, please consider to attend the [Sharing Is Caring sessions from the PnP team](https://pnp.github.io/sharing-is-caring/#pnp-sic-events) in which the Microsoft 365 PnP team provides hands-on guidance for first time contributors.

## Submission Guidelines

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
  git checkout -b working-with-files-in-libraries main
  ```

## Keeping your fork up to date

* Ensure your fork is updated and not behind the upstream **script-samples** repo. Refer to these resources for more information on syncing your repo:
  * [GitHub Help: Syncing a Fork](https://help.github.com/articles/syncing-a-fork/)
  * [Keep Your Forked Git Repo Updated with Changes from the Original Upstream Repo](http://www.andrewconnell.com/blog/keep-your-forked-git-repo-updated-with-changes-from-the-original-upstream-repo)
  * For a quick cheat sheet:

    ```shell
    # assuming you are in the folder of your locally cloned fork....
    git checkout main

    # assuming you have a remote named `upstream` pointing official **script-samples** repo
    git fetch upstream

    # update your local main to be a mirror of what's in the main repo
    git pull --rebase upstream main

    # switch to your branch where you are working, say "working-with-files-in-libraries"
    git checkout working-with-files-in-libraries

    # update your branch to update it's fork point to the current tip of main & put your changes on top of it
    git rebase main
    ```

* Push your branch to GitHub:

  ```shell
  git push origin working-with-files-in-libraries
  ```

<img src="https://pnptelemetry.azurewebsites.net/script-samples/contributing/submitting-pull-requests" aria-hidden="true" />
