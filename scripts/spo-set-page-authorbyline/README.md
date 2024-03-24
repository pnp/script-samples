---
plugin: add-to-gallery
---

# Set Page Author Byline

## Summary

Modern pages have a field called `_AuthorByLine`. When we set the value of this field of a page to the login name (or the email address) of a user, we will see the user details appear in the page header byline. However, as soon as we edit the page those details disappear. 

So, to fix that, along with the `_AuthorByLine` field, we also need to set `LayoutWebpartsContent` field of the page with the details of the user.

This script uses PnP PowerShell to set the `Authors` and `AuthorByline` properties of the `PageHeader` which inturn set the `_AuthorByLine` field and update `LayoutWebpartsContent` field of the page.

![Example Screenshot](assets/example.png)

# [PnP PowerShell](#tab/pnpps)

```powershell

    Param(
        [Parameter(mandatory = $true)]
        [string]$SiteUrl,
        [Parameter(mandatory = $true)]
        [string]$PageName,
        [Parameter(mandatory = $true)]
        [string]$UserEmail
    )

    function Set-PageAuthorByline {

        # Connect to the site
        Connect-PnPOnline -Url $SiteUrl;

        # If there is an error in the connection then return
        if ($null -eq $(Get-PnPConnection).ConnectionType) {
            return;
        }

        # Get the page object from the specified page name / url 
        $page = Get-PnPPage -Identity $PageName;

        # Return if page is not found
        if ($null -eq $page) {
            Write-Error "Page Name is not valid";
            return;
        }

        # Get the required user from the User Information list
        Write-Host "Getting user information from User Information list..." -ForegroundColor Yellow;
        $user = Get-PnPUser | Where-Object Email -eq $UserEmail;

        if ($null -ne $user) {
            Write-Host "Got user information from User Information list." -ForegroundColor Yellow;
        }
        else {
            # If not user is not present in User Information list then add the user to the list
            # This will not affect any permissions to the site
            Write-Host "User information not present in User Information list, hence adding..." -ForegroundColor Yellow;
            $user = New-PnPUser -LoginName $UserEmail; 

            # Return if the user is not found / email address is incorrect
            if ($null -eq $user) {
                Write-Error "User Name is not valid";
                return;
            }
        }

        Write-Host "Setting page header author..." -ForegroundColor Yellow;

        # Set the Authors and AuthorByLine properties of the PageHeader
        # Both these are string properties
        $page.PageHeader.Authors = "[{`"id`":`"$($user.LoginName)`"}]";
        $page.PageHeader.AuthorByLine = "[`"$($user.Email)`"]";

        # Save the chnages and publish the page
        $page.Save();
        $page.Publish();

        Write-Host "Done." -ForegroundColor Green;
        Disconnect-PnPOnline;
    }

    Set-PageAuthorByline;

    # Set-Page-Author-Byline.ps1 -SiteUrl https://tenantname.sharepoint.com/sites/sitename -PageName Page-1.aspx -UserEmail user@tenantname.onmicrosoft.com

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Anoop Tatti |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]

<img src="https://telemetry.sharepointpnp.com/script-samples/scripts/spo-set-page-authorbyline" aria-hidden="true" />