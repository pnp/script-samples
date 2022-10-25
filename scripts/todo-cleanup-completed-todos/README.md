---
plugin: add-to-gallery
---

# Cleanup completed Microsoft To Do tasks

## Summary

Microsoft To Do is my task management tool of choice, I use it for tracking everything I do, which means I generate and complete a lot of tasks during a working week.
This script iterates across all of the task lists and removes the tasks that have been marked as complete.
 
[!INCLUDE [Delete Warning](../../docfx/includes/DELETE-WARN.md)]

# [CLI for Microsoft 365 with PowerShell](#tab/cli-m365-ps)
```powershell
Write-Output "Getting Microsoft To Do task lists ..."
$lists = m365 todo list list -o json | ConvertFrom-Json

Write-Output "Iterating Microsoft To Do task lists ..."
$lists | ForEach-Object { 
    $listId = $_.Id
    
    Write-Output "Getting completed tasks from '$($_.displayName)' task list ..."
    $tasks = m365 todo task list --listId $listId -o json --query '[?status==`completed`]' | ConvertFrom-Json
    Write-Output "$($tasks.Count) completed tasks found ..."

    $tasks | ForEach-Object {
        Write-Output "Removing '$($_.Title)' task ..."
        m365 todo task remove --listId $listId --id $_.Id --confirm
    }
}

Write-Output "Done"
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
 
# [CLI for Microsoft 365 with Bash](#tab/m365cli-bash)
```bash
#!/usr/bin/env bash
# -*- coding: utf-8 -*- 

echo "Getting Microsoft To Do task lists ..."
strListIds=`m365 todo list list --query '[].id'`
arrListIds=($strListIds)

echo "Iterating Microsoft To Do task lists ..."
for strlistId in "${arrListIds[@]}"; do
    echo "Getting completed tasks from '${strlistId}' task list ..."
    strTaskIds=$(m365 todo task list --listId "${strlistId}" --query '[?status==`completed`].id')
    arrTaskIds=($strTaskIds)
    strCount=${#arrTaskIds[@]}
    echo "${strCount} completed tasks found ..."    
    for strTaskId in "${arrTaskIds[@]}"; do
        echo "Removing '${strTaskId}' task ..."
        m365 todo task remove --listId "${strlistId}" --id "$strTaskId" --confirm
    done
done

echo "Done"
```
[!INCLUDE [More about CLI for Microsoft 365](../../docfx/includes/MORE-CLIM365.md)]
***

## Source Credit

Sample first appeared on [Cleanup completed Microsoft To Do tasks | CLI for Microsoft 365](https://pnp.github.io/cli-microsoft365/sample-scripts/todo/cleanup-completed-todos/)

## Contributors

| Author(s) |
|-----------|
| Garry Trinder |


[!INCLUDE [DISCLAIMER](../../docfx/includes/DISCLAIMER.md)]
<img src="https://pnptelemetry.azurewebsites.net/script-samples/scripts/todo-cleanup-completed-todos" aria-hidden="true" />
