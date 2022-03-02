---
plugin: add-to-gallery
---

# Import taxonomy terms and labels into a term set 

## Summary

The script is to import terms and labels into a term set. The sample is a small set of terms to showcase the use case but the requirement was to import 100s of terms with labels into SharePoint Online.

The sample using PnP PowerShell to import a csv file (same format you would use for import via UI for a term set but with an additional column for labels delimited by |)

# [PnP PowerShell](#tab/pnpps)
```powershell
Connect-PnPOnline -Url https://contoso-admin.sharepoint.com/ -UseWebLogin
$envTermGroup = "Test"
$termSId = "{38e2bfe9-37a7-4f8c-856f-f65a1b6050a8}"
$csvPath = "C:\script\Status.csv"
Function Add-Synonyms($ImportCsv, $termsetId, $termGroup)
{
   #get term to add label 
   #Import CSV and create columns
   Import-Csv $ImportCsv | ForEach-Object {
    #Name and Type are the column names in the CSV
    $labels = $($_.Labels)   
    if($labels)
    {
    #determine the term level - up to 7 levels
    $i= 7
    $termName = ""
    while($termName -eq "" -and $i -ge 1)
    {
      $termName = $($_.$("Level " + $i.ToString() + " Term"))
      $i--;
    } 

    if($termName)
    {
      if($i -eq 0)
      {
       $term = Get-PnPTerm -Identity $termName -TermSet $termsetId -TermGroup $termGroup
      }
      else
      {
       $term= Get-PnPTerm -Identity $termName -TermSet $termsetId -TermGroup $termGroup -Recursive
      }
      
     if(!$term)
     {
     write-host $termName not found 
     }  
    if($term)
    {
     #split label by delimiter :
       foreach($l in $labels.split('|'))
       {
        
        $otherLabels = Get-PnPTermLabel  -Lcid 1033 -Term $term

        $otherLabel="";
        foreach($label in $otherLabels)
        {
          if($label.Value -eq $l)
            {
              $otherLabel = $label.Value;
            } 
        }
        
        if(!$otherLabel)
         {
         $term.CreateLabel($l,1033,$false)
           sleep -Seconds 5;#added wait to avoid save conflict
         }
       }
     }   
    }
   }
 }
}

#Create Term Group
try
{
 $termGroup = Get-PnPTermGroup -Identity $envTermGroup -ErrorAction SilentlyContinue
 if(!$termGroup)
 {
  New-PnPTermGroup -GroupName $envTermGroup
 }
}
Catch
{
 Write-Host "Term Group already exists"
}

Import-PnPTermSet -GroupName $envTermGroup -TermSetId $termSId -Path $csvPath -SynchronizeDeletions
sleep -Seconds 5;#added wait to make sure the terms are accessible to add labels
Add-Synonyms $csvPath $termSId $envTermGroup

```
[!INCLUDE [More about PnP PowerShell](../../docfx/includes/MORE-PNPPS.md)]
***

## Contributors

| Author(s) |
|-----------|
| Reshmee Auckloo |

[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/spo-import-taxonomy-terms-labels" aria-hidden="true" />
