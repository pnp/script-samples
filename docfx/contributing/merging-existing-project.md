# Merging your Existing GitHub Projects with this Repository

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
    git remote add origin https://github.com/yourgitaccount/script-samples.git
    git pull origin main
    ```

* Pull your other project from GitHub into the `samples` folder of your local copy of `script-samples`

    ```shell
    git subtree add --prefix=samples/projectname https://github.com/yourgitaccount/projectname.git main
    ```

* Push the changes up to your forked repository

    ```shell
    git push origin main
    ```

<img src="https://pnptelemetry.azurewebsites.net/script-samples/contributing/merging-existing-project" aria-hidden="true" />