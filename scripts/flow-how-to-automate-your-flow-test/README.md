---
plugin: add-to-gallery
---

# Script-Sample: Simple way how to automate your flowtest

## Summary

Since the [Version 6.7 CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/about/release-notes#v670) the command ["m365 flow run get"](https://pnp.github.io/cli-microsoft365/cmd/flow/run/run-get) return all the triggerInformation while using the parameter "-includetriggerInformation". 

After that you can use my Script as a base to build your own automation for testing flows. 


## Notice

With the script example I would like to give a small instruction how to automate or monitor a flowtest. This is initially only a structure for a specific use case. However, you can adapt the script relatively easily for your requirements.

In my case, the test was related to a sample Approval Flow, which performs different actions depending on the approval status.
The flow was build like that:
![Alt text](flow_build.png) 

The trigger list of the flow was built like that and die unterschiedlichen Ausführungswege basieren auf den Wert der Listenspalte "requestlevel" :
![Alt text](sharepoint_listview.png)


# [CLI for Microsoft 365 using PowerShell](#tab/cli-m365-ps)

```powershell
param(
    [Parameter(Mandatory = $true)]
    [string]$environment, 
    [Parameter(Mandatory = $true)]
    [string]$flow,
    [Parameter(Mandatory = $true)]
    [string]$spSiteUrl,
    [Parameter(Mandatory = $true)]
    [string]$spListTitle
)

$loopValue = $true
$flowRunsCount = 0
$successFlowRunsCount = 0
$failedFlowRunssCount = 0
$CancelledFlowRunsCount = 0
$powerAutomateUrl = 'https://make.powerautomate.com/'

m365 login --authType browser

#region
# ----------------------------- check environment
$checkEnvironment = m365 flow environment get --name $environment

if($checkEnvironment.Length -lt 1){
    throw 'Environment {0} not found' -f $environment
}

# ----------------------------- check flow
$flowInformation = m365 flow list --environmentName $environment --output json | ConvertFrom-Json | Where-Object -filterscript {($_.name -eq $flow) -or ($_.displayName -eq $flow)}

if($flowInformation.Length -lt 1){
    throw 'Flow {0} not found' -f $flowname
}
#endregion

#region
function getFlowRun{
    param($flowId)

    $pastFlowRuns = (m365 flow run list --environmentName $environment --flowName $flowId --output json | ConvertFrom-Json).name

    return $pastFlowRuns
}


function createTestData{
    <#
    * ADD YOUR TESTMETADATA
    * Customize this part to your system / testdata
    * trigger elements of flow runs that are not included to your testdata are not monitored
    * alternativ: just return the itemId's of manual created testdata
    #>
    $i = 0
    $testMetadata = @()

    do{
        $testMetadata += (m365 spo listitem add --contentType 'Item' --listTitle $spListTitle --webUrl $spSiteUrl --Title "Test-Item $i" --requestlevel "Started" --history "Item created automatically" | ConvertFrom-Json).Id
        $i++
    }until($i -eq 10)   

    return $testMetadata
}
#endregion


$monitorFlowRun = {
    param( 
        $environment,
        $flowId, 
        $runId,
        $spListTitle,
        $spSiteUrl,
        $testItemIds
    )

    $flowrunStatus = 'Running'

    do{
        $flowRunInformation = m365 flow run get --environmentName $environment --flowName $flowId --name $runId --includeTriggerInformation --output json | ConvertFrom-Json
        $flowrunStatus = $flowRunInformation.status
        if($flowrunStatus -eq 'Running'){
            Start-Sleep -Seconds 30
        }
    }while($flowrunStatus -eq 'Running')

    #region 
    # get Id of sharepoint element which triggers the flow
    $itemId = $flowRunInformation.triggerInformation.ItemInternalId

    <#
    * SIMULATE YOUR USERINPUT
    * Here you need to put your different update actions which simulated your user input to the sharepoint item
    * Otherwise you can delete this part and update the sharepoint item manually - with your forms or something
    #>

    # in my case i need to get the current request level 
    # based on spColoumn : requestlevel | Choice Coloumn
    $currentRequestLevel = $flowRunInformation.triggerInformation.requestlevel.Value

    #check if flowtrigger is part of testdata
    if($testItemIds -contains $itemId){

        switch($currentRequestLevel){
            'Started'{
                m365 spo listitem set --listTitle $spListTitle --id $itemId --webUrl $spSiteUrl --requestlevel 'Editing' | Out-Null
            }
            'Editing'{
                m365 spo listitem set --listTitle $spListTitle --id $itemId --webUrl $spSiteUrl --requestlevel 'Approval' | Out-Null
            }
            'Approval'{
                m365 spo listitem set --listTitle $spListTitle --id $itemId --webUrl $spSiteUrl --requestlevel 'Release' | Out-Null
            }
            'Release'{
                # this is the last step -> so there is nothing to do
            }
        }
        Write-Output $flowRunInformation
    }else{
        Write-Output('Not included in testdata - SharePoint-Item {0}' -f $itemId)
    }
    #endregion
}

$flowId = $flowInformation.name

# Get all past flowruns which are not included in your current test 
$pastFlowRuns = getFlowrun $flow

# Create new testdata
$testItemIds = createTestData

# Create an endless loop for your testrun
do{
    #region
    # ----------------------------- check for new flowruns 
    $newFlowRuns = getFlowrun $flowId
    foreach($run in $newFlowRuns){
        if(($pastFlowRuns -notcontains $run) -or ($pastFlowRuns.Length -eq 0)){
            Start-ThreadJob -ScriptBlock $monitorFlowRun -ArgumentList @($environment, $flowId, $run, $spListTitle, $spSiteUrl, $testItemIds) | Out-Null
            $pastFlowRuns += $run
        }
    }
    #endregion

    #region 
    # ----------------------------- check for completet background jobs
    Get-Job | Foreach-Object{
        if($_.State -eq "Completed"){
            $jobInformation = Get-Job -Id $_.Id
            $jobOutput = $jobInformation.Output
            if(($jobOutput | Get-Member | Where-Object Name -eq "triggerInformation").Length -gt 0){
                switch($jobOutput.status){
                    'Cancelled'{
                        $CancelledFlowRunsCount += 1
                    }
                    'Failed'{
                        $failedFlowRunssCount += 1
                    }
                    'Succeeded'{
                        $successFlowRunsCount += 1
                    }
                }
                $flowRunUrl = $powerAutomateUrl+$jobOutput.id.Split('/providers/Microsoft.ProcessSimple')[1]
                
                Write-Output("`n`nLink to Run: {0}" -f $flowRunUrl)
                Write-Output("start time of run: {0}" -f $jobOutput.startTime)
                Write-Output("for SharePoint Item | Id: {0} Title: {1}"  -f $jobOutput.triggerInformation.ItemInternalId, $jobOutput.triggerInformation.Title)
                Write-Output("`n`nFlowrun completed with state: {0}" -f $jobOutput.status)
                Write-Output("----------------------------- ")
            $flowRunsCount += 1
            }
            Remove-Job -Id $_.Id
            }
    }
    #endregion

    Start-Sleep -Seconds 30

}while($loopValue)



# run this for feedback , when you are finished

Write-Output ("Total flowruns : {0}`n "-f $flowRunsCount)
Write-Output ("succeded flowruns : {0} `n"-f $successFlowRunsCount)
Write-Output ("canceled flowruns : {0} `n"-f $CancelledFlowRunsCount)
Write-Output ("failed flowruns : {0} `n"-f $failedFlowRunssCount)


m365 logout
```
[More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)


## Configurate to your flow

### Automatic creation of test data

For an ideal test run, the test data to be created should be adapted to the corresponding requirements. This is done via the createTestData function. In this function several test data can be created either by loop or by single command [m365 spo listitem add](https://pnp.github.io/cli-microsoft365/cmd/spo/listitem/listitem-add). It is important that this function returns the IDs of the created sharepoint test items, so that when monitoring the flow runs, only the runs to the test are monitored and automatic simulated afterwards. 


```powershell
function createTestData{
    <#
    * ADD YOUR TESTMETADATA
    * Customize this part to your system / testdata
    * trigger elements of flow runs that are not included to your testdata are not monitored
    * alternativ: just return the itemId's of manual created testdata
    #>
    $i = 0
    $testMetadata = @()

    do{
        $testMetadata += (m365 spo listitem add --contentType 'Item' --listTitle $spListTitle --webUrl $spSiteUrl --Title "Test-Item $i" --requestlevel "Started" --history "Item created automatically" | ConvertFrom-Json).Id
        $i++
    }until($i -eq 10)   

    return $testMetadata
}
```

### Simulate the user input

If you can and want to simulate or adjust the user inputs, the following section gives you the opportunity to do so. By creating the test data with the script, there is a possibility that only the SharePoint test elements associated with the test will be customized. This makes it possible to test in a production system as well.

The script is designed to constantly check for new flow runs. There is also the possibility that the simulation of the test data can be skipped by commenting out and thus the user input can be performed manually. In this case you could run the evaluation or monitoring of the test with the script.

```powershell
<#
* SIMULATE YOUR USERINPUT
* Here you need to put your different update actions which simulated your user input to the sharepoint item
* Otherwise you can delete this part and update the sharepoint item manually - with your forms or something
#>

# in my case i need to get the current request level 
# based on spColoumn : requestlevel | Choice Coloumn
$currentRequestLevel = $flowRunInformation.triggerInformation.requestlevel.Value

#check if flowtrigger is part of testdata
if($testItemIds -contains $itemId){

    switch($currentRequestLevel){
        'Started'{
            m365 spo listitem set --listTitle $spListTitle --id $itemId --webUrl $spSiteUrl --requestlevel 'Editing' | Out-Null
        }
        'Editing'{
            m365 spo listitem set --listTitle $spListTitle --id $itemId --webUrl $spSiteUrl --requestlevel 'Approval' | Out-Null
        }
        'Approval'{
            m365 spo listitem set --listTitle $spListTitle --id $itemId --webUrl $spSiteUrl --requestlevel 'Release' | Out-Null
        }
        'Release'{
            # this is the last step -> so there is nothing to do
        }
    }
    Write-Output $flowRunInformation
}else{
    Write-Output('Not included in testdata - SharePoint-Item {0}' -f $itemId)
}   
```

### Evaluation of the test

The script is currently set up to use an infinite loop to monitor flow execution. If you now want to have a simple evaluation of the test run, execute the following code. In this case you will get the some information about the status of each flow execution.

```powershell
# run this for feedback , when you are finished

Write-Output ("Total flowruns : {0}`n "-f $flowRunsCount)
Write-Output ("succeded flowruns : {0} `n"-f $successFlowRunsCount)
Write-Output ("canceled flowruns : {0} `n"-f $CancelledFlowRunsCount)
Write-Output ("failed flowruns : {0} `n"-f $failedFlowRunssCount)
```

## Contributors

| Author(s) |
|-----------|
| Joshua Probst |


[DISCLAIMER](../../docfx/includes/DISCLAIMER.md)
<img src="https://m365-visitor-stats.azurewebsites.net/script-samples/scripts/template-script-submission" aria-hidden="true" />